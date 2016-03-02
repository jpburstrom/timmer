(
s.latency = 0.5;
"lib/init".import;
q.player.actionLabels = #[onset, phrase];
q.player.loadData("01");
q.player.extractFeatures;
//Connect UI to player
q.playerui.connect(q.player);
)


(
q.player.onReady = {

    ~t.klankBus = Bus.audio(s, 2);
    ~t.freqShiftBus = Bus.audio(s, 2);

    //Always-running klank synth
    ~t.klank = {

        var freqs = [1, 1.0019054878049, 1.7936737804878, 1.8009908536585, 2.5201981707317, 2.5224085365854, 2.9907012195122, 2.9940548780488, 3.7855182926829, 3.8061737804878, 4.5689024390244, 4.5754573170732, 5.0296493902439, 5.0455030487805, 6.0759908536585, 5.9094512195122, 6.4124237804878, 6.4430640243902, 7.0826219512195, 7.0923780487805, 7.3188262195122, 7.5551829268293] * 2;
        var amps = freqs.size.collect((_+1).reciprocal);
        var times = freqs.size.collect { Rand(1, 9.5) };
        var snd = DynKlank.ar(`[freqs, amps, times], In.ar(~t.klankBus, 2) * 0.01, \freq.kr(150) * LFNoise2.kr(4).range(0.99, 1.01));
        snd

    }.play(target: ~t.postGroup);

    ~t.freqShift = {
        HPF.ar(FreqShiftAA.ar(In.ar(~t.freqShiftBus, 2), \freq.kr(-100, 0.05)), 60);
    }.play(target: ~t.postGroup);


};


q.player.setIterator(p {
    var x = i = 0; //temporary index & counter
    var size = ~data.onset.size;
    var varStream = Fdef(\twoPeaksPattern).value(size).asStream;
    //Random segment: 5 segments that are selected at start
    var isPhraseStart = { |i, length=2|
        var phrase = ~data.lookup.phrase.minItem((i - _).wrap(0, inf));
        (i >= phrase) and: { (i - phrase) <= length };

    }.inEnvir;
    var allowedSegments = {
        var x = Array.series(size);
        x.removeAllSuchThat { |item|
            isPhraseStart.(item);
        };
        x = x.drop(-1);
        x
    }.value;
    var randomSegment = Plazy({Pxrand(allowedSegments.scramble[..5], inf)}).asStream;
    var prevVarFactor = 0;
    var getRadius = { |index, varFactor|
        //Convert varFactor to usable radius
        var items, clump;
        varFactor = varFactor.rand;
        if ((clump = ~data.featureClump[index]).notNil) {
            items = ~data.kdTree.radiusSearch(clump, (varFactor * 0.15) + 0.05);
            index = items.choose.label;
        };
        index
    }.inEnvir;
    var currentPhrase;

    //TODO: radius control
    loop {
        x = i; //set temporary index
        //We need to calculate which phrase we're on

        ~protoEvent.use {
            ~varFactor = varStream.next;

            //If we're going down to zero from a higher varFactor,
            //choose 5 other random segments
            if (~varFactor == 0 and: { prevVarFactor > 0 } ) {
                randomSegment.reset;
            };

            //Toss a coin. Are we random this time?
            ~isRandom = ~varFactor.coin;

        ~isPhraseStart = isPhraseStart.value(i);

            if (~isPhraseStart.not) { //Leave first 3 notes of phrase unchanged


                if (~isRandom) {
                    x = randomSegment.next;
                } {
                    //FIXME: check radius
                    x = getRadius.value(x, ~varFactor);
                }
            }

        };
        x.yield;
        i = i + 1;
    }
});
)


(
q.player.setPtn(Pbind(
    \instrument, \bufSegmentAttackSend,
    \bufRate, 1,
    \attackSendAmp, p { |ev| loop { 16.rrand(24).do { ev = 0.yield }; (ev.varFactor > 0.35).asInt.yield } },
    // \attackSendAmp, 0,
    \attackSendBus, Pfunc { ~t.klankBus },
    \sendAmp, Pfunc { |ev|
        var out = 0;
        if (ev.isPhraseStart.not and: { 0.1.coin } ) {
            out = 1;
        };
        out
    },
    \sendBus, Pfunc { ~t.freqShiftBus },
    \attackStartPos, Pkey(\startPos),
    \out, 0,
    \amp, 1 - Pkey(\sendAmp),
    //Go back and forth between orig dur and swing
    \quantAmt, Pif(Pkey(\isPhraseStart),
        Pwrand([0,1], [0.9, 0.1], inf).stutter(Plprand(5, 13)),
        0
    ),//Pseg([0, 1, 0], 20, \lin, inf),
    \dur, Pfunc { |ev|
        if (ev.isRandom) {
            ev.dur = ev.dur - 0.05.rand;
        };
        //Set swingtime
        (ev.dur * (1 - ev.quantAmt)) + (ev.quantAmt * [0.2, 0.3][ev.onset % 2])
    },

    //---Randomly shift frequency---
    \fqshift, Pwrand([0, Pwhite(-60, -200, 1)], [0.27, 0.83], inf),
    //Set synth
    \dummy, Pfunc { |ev| s.bind { ~t.freqShift.set(\freq, ev.fqshift); 0  } }

));
)
q.player.play(800);
q.player.t
q.player.stop;
q.player.streamPlayer.isPlaying
q.player.data.lookup
q.player.data.score[1]
q.player.actions.phrase.onStart = { |x| (instrument:\tick).play }