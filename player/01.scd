(
"lib/init".import;

s.latency = 0.5;
q.player.actionLabels = #[onset, phrase];
q.player.loadData("01");

q.player.extractFeatures;

//Channel map: Bass, Freqshift, Klank bell, Filterbank, piezo
);
(
q.player.onReady = {

    var compLookahead = 0.01;
    var revSize =  0.1.exprand(0.8).debug("rev size");


    ~t.klankBus = Bus.audio(s, 2);
    ~t.freqShiftBus = Bus.audio(s, 2);

   //Always-running klank synth
	//Makes a bell-like sound
    ~t.klank = Synth(\klankBell, [\inbus, ~t.klankBus, \outbus, ~t.fxOut, \amp, 0.95], ~t.postGroup);

	//Freqshift fx synth
    ~t.freqShift = Synth(\freqShift, [\inbus, ~t.freqShiftBus, \outbus, ~t.fxOut, \amp, 4, \midAmp, -3.dbamp], ~t.postGroup);

	//Filterbank acting as a kind of mellow drone,
	//with frequencies from the first 5 notes in song
	//(Harmonics of A and D + a weird harmonic from prepared G)
	~t.filterBank = Synth(\resonator_01,
        [\inbus, ~t.mainOut, \outbus, ~t.fxOut],
        ~t.postGroup
    );

    //POST FX
    ~t.softclip = Synth(\softclip,
        [\outbus, ~t.fxOut, \pregain, 4, \amp, 1],
        ~t.postGroup, \addToTail);
    ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.25, \ratio, 20, \attack, compLookahead, \release, 0.1, \amp, 0.25],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \amp, 0.25, \damp, 0.9, \size, revSize],
        ~t.sendGroup, \addToTail);

    //FIX FX LATENCY
    ~t.latencyFix = Synth(\fixedDelay,
        [\outbus, ~t.mainOut, \maxDelay, compLookahead, \delay, compLookahead],
        ~t.sendGroup, \addToTail);

};


q.player.setIterator(p {
    var introSize = 66.rrand(96);
    var size = ~data.onset.size;
    var varStream = { |sz|
        sz = sz - 15.rrand(30);
        Pseq([0, Pn(1)]) * Pseg2([1, 1, 0, 0, 0.5, 0.8, 0, 0, 1, 0.7, 0],
            Pseq([introSize, 0] ++ (size * [1,2,0.4,3,0.5,1,0.6,2].normalizeSum).floor), \cub)
        ++ Pn(0) //Make it infinite
    }.value(size).asStream;


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

	//Main counter for advancing onsets
    var counter = value({
		var repeats = 3;
		var repeatStart = 711;
		var ptn = Pseq([
            //Start with first onset
            Pn(0, 1),
            //Select `introSize - 1` random onsets
            Pwhite(0, repeatStart, introSize - 1),
            //Advance from second onsets up to `repeatStart`
            Pseries(1,1,repeatStart - 1),
			// Continue up to `repeatStart + 20.rrand(40)`, then go back to `repeatStart`
            //`repeats` times, after which it continues infinitely
            //A bit like "Tie a yellow ribbon" -- repeat the next-to-last phrase 3 times before the end.
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

q.player.setPtn(Pbind(
    \instrument, \diskSegmentAttackSend_01,
    \bufRate, 1,
    \attackSendAmp, Ptuple([
        p { |ev| loop { 16.rrand(24).do { ev = 0.yield }; (ev.varFactor > 0.35).asInt.yield } },
        Pstutter(Pwhite(2, 8), Pwrand([0, Pbrown(-36, -12, 2.8).dbamp], [0.8, 0.2], inf))
    ]),
    // \attackSendAmp, 0,
    \attackSendBus, Pfunc { [~t.klankBus, ~t.freqShiftBus] },
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
                    // q.playerui.log(qcount, "quantized");
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

    /*
	\sendAmp, p { |ev|
        var out = 0;
		var prev = 0;
		loop {

			//Shorter notes have greater probability of being frequency shifted
			if (ev.isPhraseStart.not and: { ((1 - ev.dur).max(0) * 2).coin } ) {
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
    */

    // \outbus, Pfunc { ~t.mainOut }, //[0, q.stereo.if(0, 2)],
    //Second channel is not sending to main out
    \amp, [1, 0],
    \pan, Pseg([-0.5, 0.5, -0.5], Pwhite(3.0, 8), \sin, inf).collect([0, _]),
    \startPos, Pfunc { |ev|

        var x = ~getknn.value(ev.onset, 1.rrand(5));
        x = ~data.onset[x];
        ev.attackDecay = [0.03, x[1]];
        ev.bufRate = [1, 1];
        //return startPos
		[ev.startPos, x[0]];
    },

    \strum, Pkey(\dur) * Pseg(Pwrand([Pwhite(0, 1, 1), 0.667, Pwhite(0.0, 1, 1)], [0.98, 0.01, 0.01], inf), 2),
    \fadetime, 0.002

));

)
/*EOF*/

fork {
q.player.randSeed = 1234;
q.player.play

q.player.bounce((sampleRate:96000, dur:10))

(
z.free;
z =
)