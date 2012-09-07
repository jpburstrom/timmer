//
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

//TODO:
//Midi sine
//
(
	s.waitForBoot {
		~p = Proto();
		~p.s = ();
		~p.d = ();
		~p.s.currentPath = "/Volumes/HD2/projects/timmer/kod/sc/scores/";
		(~p.s.currentPath ++ "lib/*").loadPaths;

		~p.addPrep( \snickargladje, e {
			~p.d.o = ~p.u.svdur.copy.open(~p.s.currentPath +/+ "../data/snickargladje.onsets").normalized_(true);
			//do stuff
		});

		~p.prep;

	}
)


(
//INIT

SynthDef("timmer.grain4", { arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, attack = 0.1, decay = 0.02, curve= -8, out;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos) * BufFrames.kr(bufnum);	
	#l, r = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.perc(attack, dur, curve:curve), doneAction: 2);
	OffsetOut.ar(out, Balance2.ar(l, r, pan, amp))
}).store;

SynthDef("timmer.grainX", { arg distance=1, revOutG=2, revOutL=4, startPos, dur, bufnum, bufRate = 1, pan = 0, attack = 0.1, decay = 0.02, curve, out;
	var env, l, r, panspec, hpspec, lpspec, fakedistance, widthspec, hp, lp, amp, revamp, revampG, revampL, width, sound;
	
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = startPos * BufFrames.kr(bufnum);
	
	lpspec = ControlSpec(20000, 1000, \exp);
	hpspec = ControlSpec(40, 500, \exp);
	widthspec = ControlSpec(-1, 0);
	//distance = MouseY.kr;
	//pan = MouseX.kr(-1, 1);
	hp = hpspec.map(distance);
	lp = lpspec.map(distance);
	fakedistance = (distance * 9 + 1);
	amp = fakedistance.reciprocal;
	revamp = 1 / fakedistance.sqrt;
	revampG = revamp * amp;
	revampL = revamp * 1 - amp;
	width = widthspec.map(distance);
	width = -1;
	//pan = pan * (width.abs * 0.5 + 0.5);
	
	sound = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.ar(Env.perc(attack, decay, curve: curve), doneAction: 2);
	#l, r = LPF.ar(HPF.ar(sound, hp), lp);
	sound = [LinXFade2.ar(l, r, width), LinXFade2.ar(r, l, width)];
	sound = Pan2.ar(sound, [(pan - 1).clip(-1,0), (pan + 1).clip(0, 1)]).sum;
	OffsetOut.ar(out, sound);
	OffsetOut.ar(revOutG, sound * revampG);
	OffsetOut.ar(revOutL, sound * revampL);	
}).store; 


//~scmirfile = SCMIRAudioFile("/Volumes/HD2/projects/timmer/render/to SC/hits-new.wav").extractOnsets;
~scmirfile = SCMIRAudioFile("/Volumes/HD2/projects/timmer/render/NR/boat-putter-s 20120810-175741.wav").extractOnsets;
~onsets = (~scmirfile.onsetdata) / ~scmirfile.duration;
~birds = [12,12,12,16,16,24,24,24,4,8,64,32,62.060606];

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
//TESTING...

Pseq(Plorenz())

Array
