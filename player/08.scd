//# Template for songs ###

//## Initialize ###
(
var relPath = "".resolveRelative;
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;
//To be called from within q.player environment
var spawnResonatorSynth = {
    ~t.resonator = Synth(\resonate_08, [\sendbus, ~t.convBus], ~t.postGroup);

};
"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("08");
//q.player.extractFeatures;
// q.playerui.connect(q.player);
// q.markov = "/lib/protos/markov-trainer".import;

//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar
q.player.onReady = {

	~t.irSpectrum = 2.collect {|i|
		Buffer.read(s, relPath +/+ "data/impulses/impulse-closed-ms-48_NRT_%.wav".format(i));
	};
    ~t.convBus = Bus.audio(s, 2);
	s.sync;

	~t.conv = Synth(\msConv, [\inbus, ~t.convBus, \outbus, 0, \irbufs, ~t.irSpectrum,
		\sideAmp, 1, \amp, 0.25
	], ~t.sendGroup);

	~t.handclaps = handClapPaths.pathMatch.collect { |path|
		Buffer.read(s, path);
	};

	//TODO: separate send bus for reverb
	~t.reverb = Synth(\plate_reverb_2x2, [\amp, -3.dbamp,
		\bandwidth, 5000, \decay, 0.01, \predelay, 10, \excursion, 0.9,
		\in_diff1, 0.36, \in_diff2, 0.40
	], ~t.sendGroup);

		spawnResonatorSynth.value;

};



q.player.data.grouping = #[
	//Part one, onset groups
	[ 0, 1, 2, 3, 1, 4, 5, 1,
        6, 7, 1, 7, 8, 9, 7, 10,
        7, 11, 12, 13, 7, 12, 14, 9,
        15, 7, 12, 14, 16, 17 ]
];
q.player.data.iterators = ().make {
	//Scramble order of first part, but don't put two in the same group after each other
	~p1 = Plazy { Pseq(Fdef(\scrambleAvoidSimilar).(q.player.data.grouping[0])) } ;
	~p2 = Pseries(30, 1, 34);
	~p3 = Plazy {
		Pseq((64..76).scramble)
		++ Pseq((77..80))
		//This is a bit
        ++ Pwalk((81..90), Pwrand([-2, 1, 2], [0.3, 0.4, 0.4], 30.rrand(50)))
	};
	// ~p4 = Pn(91,1) ++ Pxrand((92..104), 24) ++ Pn(105, 1);
	~p4 = Pseq((91..105));
	~p5 = Pseq((106..301));
	//Break it down
	~p6 = Pseries(302);
	// ~p7 = Pn(0);
};


//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Plazy({
	var endSegment = 360.rrand(370);

	Pbind(
		\startPos, Pkey(\startPos) - 0.002,
		\dummy, Prout({ |ev|

			var claps = Pn(Plazy { Pseq(~t.handclaps.scramble) }).asStream;
			//Weird, but works: since claps2 is a stream, and played in parallel,
			//we can return nil whenever we want a rest
			var claps2 = Pseq([nil, nil, Pfuncn{ claps.next }], inf).asStream;
			var blacklist = (118..122) ++ (134..139) ++ (175..186) ++ (192..199);

			var endDuration = 40.rrand(55);
			var plankStream;

			while ({ev.onset < 105}) {
				//Weird and strange: spawn a 1-item pattern for every onset...
				~spawner.par(Pbind(
					\instrument, \bufSegment,
					\bufnum, Pfunc { claps2.next },
					\amp, Pn(0.1, 1),
					\timingOffset, Pwhite(-0.02, 0.02),
					\group, Pfunc { ~t.mainGroup }
				));
				ev = 0.yield

			};

			~t.resonator.free; //FIXME: release

			while ({ev.onset < 218}) {
				if ( blacklist.includes(ev.onset).not and: { 0.7.coin } ) {
					//Weird and strange: spawn a 1-item pattern for every onset...
					~spawner.par(Pbind(
						\instrument, \bufSegment,
						\bufnum, Pfunc { claps.next },
						\amp, Pn(0.3, 1),
						\timingOffset, Pwhite(-0.02, 0.02),
						\group, Pfunc { ~t.mainGroup }

					));
				};
				ev = 0.yield
			};

			while ({ev.onset < 301}) {
			ev = 0.yield;
			};

			plankStream = ~spawner.par(Pbind(
				// \instrument, \bufSegment,
				\bufnum, Pfunc { claps.next  },
				\instrument, \bufSegmentPlankS,
				// \bufnum, Pfunc { ~protoEvent.bufnum },
				// \startPos, Pfunc({ ~data.onset.flop[0][~currentEvent.onset.postln] }),
				\amp, 5,//Pbrown(0.2, 0.5),
				\dur, Fdef(\pFuzzyBeatMatch).(q.player.data.onset[301..368].flop[1], 5),
				\legato, Pwhite(0.2, 2.0),
				\freq, 60,
				\group, Pfunc { ~t.mainGroup }
			));

			//while playing through, yield zero
			//Then advance to the next pattern in the Pseq
			while ({ev.onset <= endSegment}) {
				ev = 0.yield;
			};
			~spawner.suspend(plankStream);
			spawnResonatorSynth.value;
			//Parallell pattern, which continues after the main pattern has been silenced
			//(see below)
			~spawner.par (
				Pfindur(endDuration + ev.dur, Pchain(
					Pbind(
						\instrument, \bufSegmentPlankS,
						\bufnum, Pfunc { claps.next },
						// \startPos, Pxrand(~data.onset.flop[0], inf),
						\amp, Pkey(\amp) * 2,
						// \test, Pfunc { "hello".postln },
						\pan, 0.2,
						\freq, 60,
						\group, Pfunc { ~t.mainGroup }
					),
					Pdef(\t08randomizedBeginning)
				))
			);

			//Silence this, but continue running until `t08RandomizedBeginning` stops
			//FIXME: This doesn't really work
			Pfindur(endDuration, Pfunc { |ev|
				0
			}).embedInStream(ev);

		}),
		//TEMP: Shorten last non-freqshifted note, so we don't get start of next attack
		\dur, Pif(Pkey(\onset) == (endSegment), Pkey(\dur) - 0.05, Pkey(\dur)),
		// \amp, 0,
		\instrument, Pif(Pkey(\onset) < 370, \bufSegment, \bufSegmentFreqshift),
		\freqshift, -5000.rrand(-8000);
	)

}));
//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Plazy { Psym(Pseq(#[p1, p2, p3, p4, p5, p6]), ~data.iterators) });
// q.player.setIterator(Pseries(301));
// q.player.play
)

/*EOF*/

q.player.play

q.player.bounce((dur: 10))

