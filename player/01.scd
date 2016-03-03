(
s.latency = 0.5;
"lib/init".import;
q.player.actionLabels = #[onset, phrase];
q.player.loadData("01");
q.player.extractFeatures;
//Connect UI to player
q.playerui.connect(q.player);
)

//TODO:
//Check radius
//Check fqshift (multiple of phrase drone freq?)
//quantAmt lag (interpolate)
//Room/rev
//~6.30: Work with shorter durations



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
    var size = ~data.onset.size;
    var varStream = Fdef(\twoPeaksPattern).value(size).asStream;
    //Random segment: 5 segments that are selected at start
    var isPhraseStart = { |i, length=2|
        var phrase = ~data.lookup.phrase.minItem((i - _).wrap(0, inf));
        (i >= phrase) and: { (i - phrase) <= length };

    }.inEnvir;
	var allowedSegments = ~data.onset.selectIndices( { |x| x[1] > 0.6 and: { x[1] < 1.0 } });
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

	//`counter` is a stream that advances up to `repeatStart + 20.rrand(40)`, then goes back to `repeatStart`
	//`endRepeats` times, after which it continues infinitely
	var counter = value({
		var repeats = 3;
		var repeatStart = 711;
		var ptn = Pseq([
			Pseries(0,1,repeatStart),
			Pn(Plazy{Pseries(repeatStart, 1, 20.rrand(40))}, repeats - 1),
			Pseries(repeatStart)
		]);
		ptn.asStream;
	});

	var x, i = counter.value; //temporary index & counter


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

            prevVarFactor = ~varFactor;
            // prevVarFactor.postln;

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
            };
			~origIndex = i;
        };
	    x.yield;
        i = counter.value;
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
    \quantAmt, p({ |ev|
		var lookup = ~data.lookup.phrase;
		//Set the base probability to median phrase length
		//so that probBase / 0.9 makes a quantize curve happen every phrase
		//0.9 is a magic number
		var prob, probBase = 0.9 * lookup.differentiate[1..].median.reciprocal;
		var qcount=0;
		loop {
			//Check that we're not in the beginning of a phrase
			//if not, flip a coin

			//make a sawtooth probability curve,
			//starting at zero, going up to 0.9 * probBase,
			//and wrapping back to zero roughly 60 onsets before ending
			prob = probBase * (ev.origIndex / 740).wrap(0,1) * 0.9;
			ev.qprob = prob; //For tracingd

			//Check for ev.phrase not nil because for some reason it choked on that one time
			if (ev.isPhraseStart.not and: {  prob.coin } and: { ev.phrase.notNil } ) {
				//Calculate number of onsets to next phrase start
				var len = ~data.lookup.phrase[ev.phrase + 1];
				var curve = 2.rrand(8);
				var minlength = 4;
				//We don't want to start a quantize curve if we're to close to next phrase
				if (len.notNil and: { len >= minlength }) {
					len = len - ev.onset;
					//Embed envelope in stream
					//Handle odd lengths gracefully
					qcount = qcount + 1;
					q.playerui.log(qcount, "quantized");
					Pseg2([0,1,0], Pseq([len + 1, len].div(2)), Pseq([curve.neg, curve])).embedInStream(ev);
				};

			};

			//0 is the default
			ev = 0.yield;


		}
	}),
	\dur, Pfunc { |ev|
        if (ev.isRandom) {
            ev.dur = ev.dur - 0.05.rand;
        };
		//Set quantization
        (ev.dur * (1 - ev.quantAmt)) + (ev.quantAmt * 0.3) //0.3 is less than minimum onset length
    },

    //---Randomly shift frequency---
    \fqshift, Pwrand([0, Pwhite(0, -40, 1)], [0.27, 0.83], inf),
    //Set synth
    \dummy, Pfunc { |ev|
        //FIXME: this causes late messages when fast-forwarding
        //And is a hack anyway
        s.bind { ~t.freqShift.set(\freq, ev.fqshift); };
        0
    }

));
)
q.player.play(0);
q.player.stop;
q.playerui.log("hello")
q.player.data.lookup.phrase.differentiate[1..].median.reciprocal
.div(3).reciprocal
q.playerui.log(3, "quantized");



Pbind(\dur, Pxrand(q.player.data.onset.flop[1].select( { |x| x > 0.6 and: { x < 1.0 } }).scramble.keep(5), inf)).play;

q.player.data.onset.flop[1].select( { |x| x > 0.6 and: { x < 1.0 } }).scramble.keep(5)

