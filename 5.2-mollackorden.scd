//
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

//TODO:
//Midi sine
//
~p = nil;
Server.default = Server.local;
(
	s.waitForBoot {
		~p ?? {
			~p = Proto();
			~p.name = "snickargladje";
			~p.s = ();
			~p.d = ();
			~p.s.currentPath = "/Volumes/HD2/projects/timmer/kod/sc";
			(~p.s.currentPath +/+ "scores/lib/*").loadPaths;

			~p.addPrep( \snickargladje, e {
				~p.d.durations = ~p.u.svdur.copy.open("snickargladje-bass.aiff");
				~p.d.gdur = ~p.u.svdur.copy.open("greppbrada-1.wav");
				~p.readBuffer(\greppbrada1, "greppbrada-1.wav");  
				~p.readBuffer(\strak1, "impulse-strak.wav");
				~p.readBuffer(\nothing, "Nothing-excerpt.wav");
				~p.readBank(\huff, "part4-huff");
				~p.readBank(\hits, "hits");
				~p.meap.open("impulse-strak.wav.feat");

				Pdef.defaultQuant = 0;
				//do stuff
				~pw = ~p.wrapper.copy;
			}, 1);
		};

		~p.run(
			e {
			~pw !? { ~pw.dropValue = 1 };
			~pw.pattern = Pbindf(~p.d.durations) <> 
				Pbindf(Pdef(\impulseStringChords), \attack, 0, \db, -33, \softness, 0);
		
			//Add routines
			~pw.onCounter = ();
			~pw.onFirst = {
				Pdef(\nothing).play;
			};
			~pw.onEvery = e { |ev|
				/*
					(Pbind(\dur, Env([0.05,0.2].mirror, [0.5,0.5] * ev.dur, \sin)) <>
						Pdef(\strakArp).asPattern.repeat).play
						*/

				//ev.postln;
			};
			Pdef(\main, ~pw).play;
		});
	}
);
 ~p.d.durations.peakEnv(0, 1, \sin, 2, [0.33, 0.34, 0.33]).plot
Env

Pbind(\dur, Env.linen([1,0.1,0.1,1], [1,4,1].normalizeSum * 2)).play
[1,0.1].mirror

Env([1,0.1,0.1,1], [1,0,1].normalizeSum * 10, \sin).plot;

~p.d.notes.asStream.next(())
(

SynthDef("timmer.grain4", { arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, attack = 0.1, decay = 0.02, curve= -8, out;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos) * BufFrames.kr(bufnum);	
	#l, r = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.perc(attack, dur, curve:curve), doneAction: 2);
	OffsetOut.ar(out, Balance2.ar(l, r, pan, amp))
}).store;

PdefAllGui(32)
b = Buffer.read(s, "/Volumes/HD2/projects/timmer/samples/greppbrada-1.wav")

)
Synth('timmer.grainPerc', [\bufnum, b])

(

	)
	(

		Pbind(
			\instrument, 'timmer.grainPerc',
			\bufnum, b,
			\harmonic, 1,
			\dur, Pbrown(0.09, 0.11),
			\legato, Pkey(\dur) * 25,
			\db, Pseq([0, Pseq(5.collect(-6))], inf),
			\attack, 0.01,
			\startPos, Pseq([~p.d.gdur.durations[8], Pxrand(~p.d.gdur.durations, 5)], inf) + 0.1,
			\pan, Pkey(\startPos) * 2 - 1,
			\curve, -6,
			\out, 0,
		).play
)
(
p.stop;
p = Pproto(
	makeFunction: {
		~bufnum = (type: \allocRead, path:"/Volumes/HD2/projects/timmer/render/NR/boat-putter-s 20120810-175741.wav" ).yield; 		//~bufnum = (type: \allocRead, path:"/Volumes/HD2/projects/timmer/render/to SC/hits-new.wav" ).yield; //"/Volumes/HD2/projects/timmer/kod/sc/pattern-score.scd"
	},
	pattern: 
		Pfindur(300, Pseq([
		Pbind(\type, \rest, \delta, Pseq([0.01])),
		Pbind(
		\instrument, 'timmer.grainX',
		\type, \on,
		\bufRate, 1,
		\dur, 0.1,
		\delta, Pbrown(0.2, 0.21, 0.02),
		//\delta, Pseq(Array.geom(20, 1, 1.2).reciprocal),
		\startPos, Pwhite(0.0, 1),
		\pan, Pkey(\startPos) * 2 - 1 * 0,
		//\bufnum, Pseq([d], inf),
		\amp, 1,
		\attack, 0,
		\curve, -20,
		\out, 0,
		\pan, 0
		)
		])
		));
		//NRT .render(~filename, 310, sampleRate:48000, headerFormat: "WAV", sampleFormat: "int24", options: ServerOptions.new.numOutputBusChannels_(2), action: { 0.exit } )

	
~lor = ([1,2,3]).sort({0.5.coin});
~items = Array.fill(~lor.size, { |i|
		Pseq([
			Pbind(\type, \rest, \delta, Pseq([0.0.rrand(1)])),
			Pbindf(p, \foo, Plorenz(8), \delta, Pfunc({|e| e.foo[0]; }), \amp, Pexprand(0.1, 1), \distance, i.reciprocal, \attack, Pkey(\delta), \decay, Pkey(\attack) )
		]);
	});

Ppar(~items).play
)



