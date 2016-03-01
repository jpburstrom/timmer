(
"lib/init".import;
q.player.actionLabels = #[onset, region];
q.player.loadData("01");
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
        DynKlank.ar(`[freqs, amps, times], In.ar(~t.klankBus, 2) * 0.01, \freq.kr(150) * LFNoise2.kr(4).range(0.99, 1.01));
    }.play(target: ~t.postGroup);

    ~t.freqShift = {

        FreqShiftAA.ar(In.ar(~t.freqShiftBus, 2), \freq.kr(-100));
    }.play(target: ~t.postGroup);


};
q.player.setIterator(p {
    var i = 0;
    var size = ~data.onset.size;
    var varStream = (Pseg2([0, 0, 1, 1, 0],
        Pseq((size * [1,2,1,2].normalizeSum).floor)) ++ Pn(1)).asStream;
    //select random segment
    var randomSegment = Pxrand(Array.series(size).scramble[..5], inf).asStream;

    //TODO: radius control
    loop {
        var x = i;
        ~protoEvent.use {
            ~varFactor = varStream.next;
            ~isRandom = ~varFactor.coin;
            if (~isRandom) {
                x = randomSegment.next;
            };
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
    \sendAmp, p { |ev| loop { 16.rrand(24).do { ev = 0.yield }; (ev.varFactor > 0.35).asInt.yield } },
    \sendBus, Pfunc { ~t.klankBus },
    \sendAmp, 1,
    \sendBus, Pfunc { ~t.freqShiftBus },
    \attackStartPos, Pkey(\startPos),
    \out, 34,
    \db, 0,

    //Go back and forth between orig dur and 0.3
    \quantAmt, 1, //Pseg([0, 1, 0], 20, \lin, inf),
    \dur, Pfunc { |ev| (ev.dur * (1 - ev.quantAmt)) + (ev.quantAmt * [0.2, 0.3][ev.onset % 2]) },

    //---Randomly shift frequency---
    \fqshift, Pwrand([0, Pwhite(-60, -100, 1)], [0.27, 0.83], inf),
    //Set synth
    \dummy, Pfunc { |ev| s.bind { ~t.freqShift.set(\freq, ev.fqshift); 0  } }

));
)
q.playerui.follow = nil

q.player.play;
q.player.stop;

s.bind { q.player.t.freqShift.set(\freq, -100.rrand(-2000).postln) }