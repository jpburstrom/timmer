//# 04 #

//Exploring different ways of randomizing phrases
//See iterator for details

//For later, needs more interesting sound. Explore parallel freqshifted track, or something similar

//## Initialize ###
(
var markov;
"lib/init".import;
q.player.actionLabels = #[phrase, part];
q.player.tickLabel = \phrase;
q.player.loadData("04");
//Adjust this to avoid clicks
q.player.numBufs = 32;
//q.player.extractFeatures;
// q.playerui.connect(q.player);


SynthDef(\freqshiftPostEQ_04, {
    var snd = In.ar(\inbus.kr, 2);
    snd = SoftClipAmp8.ar(snd, 1, 1);
    snd = BHiShelf.ar(snd, \freq.kr(2700), 2, -12);
    Out.ar(\outbus.kr, snd);
}).add;

//This loads a previously generated markov chain
markov = "lib/protos/markov-trainer".import;
markov.setBounds(q.player.data.lookup.part[2], q.player.data.lookup.part[3] - 1);
markov.connect(q.player);
markov.initChain;

q.player.onReady = {
    var compLookahead = 0.01;
    var revSize = 2;

    //Freqshift needs a bit of hi cut, because of noise
    ~t.freqshiftbus = Bus.audio(s, 2);
    ~t.freqshiftEq = Synth(\freqshiftPostEQ_04, [\inbus, ~t.freqshiftbus, \outbus, ~t.fxOut], ~t.postGroup);

    /*
	~t.reverb = Synth(\plate_reverb_2x2, [\amp, -3.dbamp,
        \bandwidth, 5000, \outbus, q.stereo.if(0,4), \decay, 0.01, \predelay, 10, \excursion, 0.9,
		\in_diff1, 0.46, \in_diff2, 0.40
	], ~t.sendGroup);
    */

      //POST FX
    ~t.softclip = Synth(\softclip,
        [\outbus, ~t.fxOut, \pregain, 1, \amp, 1],
        ~t.postGroup, \addToTail);
    ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.5, \ratio, 8, \attack, compLookahead, \release, 0.05, \amp, 0.5],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \time, 0.4, \amp, 0.1, \damp, 0.7, \size, revSize],
        ~t.sendGroup, \addToTail);

    //FIX FX LATENCY
    ~t.latencyFix = Synth(\fixedDelay,
        [\outbus, ~t.mainOut, \maxDelay, compLookahead, \delay, compLookahead],
        ~t.sendGroup, \addToTail);
};

//Modifying pattern
q.player.setPtn(Pbind(
	//Adjust duration so next attack doesn't cause clicks
	\dur, Pkey(\dur) - 0.01,
	//if not normal, anything could happen
	\normal, Prout({ |ev|
		var norm=true, time=0;

        norm = true;
		loop {



			//Make sure two 'normal' segments aren't playing simultaneously.
			if (norm) {
				//Save current time plus segment duration
				time = thisThread.seconds + ev.dur;
			};

			ev = norm.yield;

			if (time < thisThread.seconds) {
				//If a normal segment isn't playing,
				//toss a coin to see if this segment should be normal
                //If part 2, normal is not likely
                if (ev.part == 2) {
                    norm = 0.01.coin;
                } {
                    // if other parts than 2, normal is more likely
                    norm = 0.1.coin;
                }
			} {
				//If a normal segment is playing, set normal to false
				norm = false;
			};

            if (ev.phrase >= 46) {
                norm = true;
            };

            //TEST
            if (ev.part > 2) {
                norm = true
            };

            norm
		}
	}),
	//TODO: generalize separate keys into a chained Psym or something
    //TODO: use 2-channel version of file
	\instrument, Pif(Pkey(\normal), \diskSegment, Pwrand([\diskSegmentFreqshift, \diskSegmentPlank, \diskSegmentResonance], [0.75, 0.15, 0.10], inf)),
    //Output to main out, except for all fx
    //If freqshift, output to its own bus for post eq
    \outbus, Pif(Pkey(\normal), Pfunc { ~t.mainOut },
        Pif(Pfunc { |ev| ev.instrument == \diskSegmentFreqshift }, Pfunc { ~t.freqshiftbus}, Pfunc { ~t.fxOut })
    ),

 	\freqshift, Pwhite(-200, -2000),
	\fadetime, 0.02,
    //Notes for resonance & klank
    \midinote, Prand(Array.series(8, 33, 1), inf),
    //FIXME: rate
    \rate, Pif(Pkey(\normal), 1, Pwrand([0.5, 1], [0.1, 0.9].normalizeSum, inf)),
    \dur, Pif(Pfunc { |ev|
        ev.normal or: {
			ev.phrase >= 46 //46 and 47 are possible last phrases;
		}
	},
		Pkey(\dur) - 0.1, Pkey(\dur) * Pwhite(0.4, 1) * Pseg(Pseq([Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1, 1)], inf), Pwhite(5, 20))),
    //Set first segment to fixed short length
    \dur, Pfunc { |ev| if (ev.phrase == 0) { ev.dur = 0.1.rand }; ev.dur },
    //Adjust first segment start position
    \startPos, Pfunc { |ev|
        if (ev.phrase == 0) {
            var pre = ev.startPos.rand;
            ev.startPos = ev.startPos - pre;
            ev.dur = ev.dur + pre;
        };

        ev.startPos;
    },
	\delta, Pif(Pfunc { |ev|
        ev.normal and: { ev.part < 2 and: { ev.phrase > 0 }}
    },
        //If normal, start playing next segment after 0-5 seconds
        Pwhite(0.0, 0.5),
        Pkey(\dur)
    ),
    \pan, Pif(Pkey(\normal), 0, Pseg(Plprand(0, 0.8) * Prand([-1,1], inf), Pwhite(0.01, 2), \sin)),
    \hello, Pfunc { |ev|
        if (ev.instrument == \bufSegmentResonance_3ch) {
            ev.freq = #[40,45,50,55].midicps.choose;
            ev.fadetime = 0.1;
        };

		0;
	},
    //Amp adjustment for different instruments
    \amp, Pfunc { |ev|
        var amp = ev.amp ? 1;
        var fact = switch(ev.instrument,
            \diskSegmentPlank, { 0.125.rrand(0.25) },
            \diskSegmentFreqshift, {
                ev.freqshift.explin(-2000, -200, 4, 1)
            },
            //default
            { 1 }
        );
    }
));

//Iterator
q.player.setIterator(
	Plazy({
		var part = ~data.lookup.part;
        var mk = MarkovSet(markov.markovSet);
        // var pt2len = (part[3] - part[2]) + 1;
        var pt2len = 66;
		Pseq([
			//First phrase is always the same
			0,
			//Part 0 have randomized phrases
			Pn(Plazy({ Pseq(Array.series(part[1]-1, 1).scramble) }), 6),
			//Part 1 is sequential
			Pseries(part[1], 1, part[2]-part[1]),
			//TODO: How long will this go on? How should we transition?
            Pfin(pt2len, p {
				var x=part[2].rrand(part[3]-1);
				~t.repeats = (part[2]..part[3]).collectAs(_->0, Event);
				loop {
					~t.repeats[x] = ~t.repeats[x] + 1;
                    x.yield;
                    x = mk.next(x);
                }
            }),
			//Part 3 is random, and plays at least n-1 phrases
			Pseq((part[3] .. ~data.phrase.size - 2).scramble),
            //If last phrase is not the next-to-last in the song, go on with the very last phrase
			Pif(Pfuncn({ ~currentEvent.phrase != 46 }), q.player.data.phrase.size - 1, nil)


		]);
	})
);

// q.player.play
)


/*------------------------------------------------------------*/
/*EOF*/
/*------------------------------------------------------------*/

q.player.play
3.do {
    q.player.bounce((sampleRate:96000))
}
~buf4 = Buffer.read(s, "songs/04*.wav".resolveRelative.pathMatch.last);
