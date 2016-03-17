(
s.latency = 0.5;
"lib/init".import;
q.player.actionLabels = #[onset, phrase];
q.player.loadData("01");
//Connect UI to player
q.playerui.connect(q.player);
q.player.extractFeatures;

)

q.player.bounce;
q.player.play
q.player.stop

//TODO:
//~6.30: Work with shorter durations

(
q.player.onReady = {

    ~t.klankBus = Bus(\audio, 32, 2);
    ~t.freqShiftBus = Bus(\audio, 34, 2);

	//Always-running klank synth
	//Makes a bell-like sound
	~t.klank = Synth(\klankBell, [\inbus, ~t.klankBus, \outbus, 0], ~t.postGroup);

	//Freqshift fx synth
    ~t.freqShift = Synth(\freqShift, [\inbus, ~t.freqShiftBus, \outbus, 0, \amp, 4, \midAmp, -9.dbamp], ~t.postGroup);


};

q.player.setIterator(p {
    var size = ~data.onset.size;
    var varStream = Fdef(\twoPeaksPattern).value(size).asStream;

	//We have a list of phrase start/durations. This compares current onset start
	//with the phrase start, to see if the new onset marks a start of the phrase
	var isPhraseStart = { |i, length=2|
        var phrase = ~data.lookup.phrase.minItem((i - _).wrap(0, inf));
        (i >= phrase) and: { (i - phrase) <= length };

    }.inEnvir;

	//Get k-nearest neighbour, with a distance from 0 to 1
	//By default we have 5 neighbours calculated
    var getknn = { |index, varFactor|
        //We offset varFactor with 0.9999 and multiply with number of knn items
        //so that even a very small varFactor will switch to closest neighbour
        varFactor = ((~knnSize * varFactor) + 0.9999).floor;
        index = ~getknn.value(index, varFactor);
    }.inEnvir;

	//Here we decide which 5 segments should be special.
	//Allowed segments: short or long (but not very long)
    var allowedSegments = ~data.onset.selectIndices( { |x| x[1] < 0.4 or: { x[1] > 1.0 and: { x[1] < 2 }} });
    //Pick five random of allowed segments
	var randomSegment = Plazy({Pxrand(allowedSegments.scramble[..5], inf)}).asStream;

	//Cache last `varFactor`
	var prevVarFactor = 0;

	//`counter` is a stream that advances up to `repeatStart + 20.rrand(40)`, then goes back to `repeatStart`
	//`repeats` times, after which it continues infinitely
	//A bit like "Tie a yellow ribbon" -- repeat the next-to-last phrase 3 times before the end.
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

            //Toss a coin. Are we random this time?
            ~isRandom = ~varFactor.coin;

			//Check if we are
			~isPhraseStart = isPhraseStart.value(i);

			//Bypass if we're on a phrase start
            if (~isPhraseStart.not) {
				if (~isRandom) {
                    x = randomSegment.next;
                } {
                    //Get neighbour. A random number from 0 to ~varFactor is selecting the
                    //n closest neighbour (where ~varFactor is a float from 0-1).
                    //FIXME: too much random
					x = getknn.value(x, ~varFactor.rand * ~varFactor.coin.binaryValue);
                    // x = i;
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
    \attackStartPos, Pkey(\startPos),
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

    //Random frequency shift
	//Where 75hz = D1
	\fqshift, Pxrand((5..8) * -75, inf),

	\sendAmp, p { |ev|
        var out = 0;
		var prev = 0;
		loop {

			//Shorter notes have greater probability of being frequency shifted
			if (ev.isPhraseStart.not and: { q.playerui.log(((1 - ev.dur).max(0) * 2)).coin } ) {
				//Ok, we're setting freqshift params from here, which probably would be regarded
				//as a big hack.
				s.bind { ~t.freqShift.set(\freq, ev.fqshift); };
				ev = 1.yield;
				3.do { ev = 0.yield }
			} {
				ev = 0.yield;
			};

			prev = ev.dur;

    	};
	},
    \sendAmp, Ptuple([0, Pbrown(-12, 6, 0.8).dbamp], inf),
    \sendBus, Pfunc { ~t.freqShiftBus },
    \out, 0,
    \amp, [1, 0],
    \startPos, Pfunc { |ev|

        x = ~getknn.value(ev.onset, 1.rrand(5));
        x = ~data.onset[x];
        ev.sustain = [ev.dur, x[1] - 0.1];
        //return startPos
		[ev.startPos, x[0]];
    },
    //lag doesn't work with bounce?
	//see fix at ../tests/scoreClock-lagfix.scd
	// \lag, Pwhite(0.0, 0.04).clump(2) * [0, 1],
    \fadetime, [0.002, 0.002]
));

)
