//
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };

//TODO:
//Midi sine
//

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

SynthDef("timmer.grainX", { arg distance=1, revOutG=2, revOutL=4, startPos, dur, bufnum, bufRate = 1, pan = 0, attack = 0.1, decay = 0.02, out;
	var env, l, r, panspec, hpspec, lpspec, fakedistance, widthspec, hp, lp, amp, revamp, revampG, revampL, width, sound;
	
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = startPos * BufFrames.kr(bufnum);
	
	lpspec = ControlSpec(20000, 300, \exp);
	hpspec = ControlSpec(40, 1200, \exp);
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
	//pan = pan * (width.abs * 0.5 + 0.5);
	
	sound = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.linen(1, dur, 1), doneAction: 2);
	#l, r = LPF.ar(HPF.ar(sound, hp), lp);
	sound = [LinXFade2.ar(l, r, width), LinXFade2.ar(r, l, width)];
	sound = Pan2.ar(sound, [pan, pan]).sum;
	OffsetOut.ar(out, sound);
	OffsetOut.ar(revOutG, sound * revampG);
	OffsetOut.ar(revOutL, sound * revampL);	
}).store;

~scmirfile = SCMIRAudioFile("/Volumes/HD2/projects/timmer/render/to SC/hits-new.wav").extractOnsets;
~onsets = (~scmirfile.onsetdata - 0.5) / ~scmirfile.duration;
~birds = [12,12,12,16,16,24,24,24,4,8,64,32,62.060606];

)


(
p.stop;
p = Pproto(
	makeFunction: {
		~bufnum = (type: \allocRead, path:"/Volumes/HD2/projects/timmer/render/to SC/hits-new.wav" ).yield; //"/Volumes/HD2/projects/timmer/kod/sc/pattern-score.scd"
	},
	pattern: 
		Pfindur(300, Pseq([
		Pbind(\type, \rest, \delta, Pseq([0.01])),
		Pbind(
		\instrument, 'timmer.grainX',
		\type, \on,
		\bufRate, 1,
		\dur, 0.55,
		\delta, Pbrown(0.2, 0.21, 0.02),
		//\delta, Pseq(Array.geom(20, 1, 1.2).reciprocal),
		\startPos, Pxrand(~onsets, inf),
		\pan, Pkey(\startPos) * 2 - 1 * 0,
		//\bufnum, Pseq([d], inf),
		\amp, 1,
		\attack, 0.5,
		\curve, Pwhite(-8, -16),
		\out, 0
		)
		])
		));
		//NRT .render(~filename, 310, sampleRate:48000, headerFormat: "WAV", sampleFormat: "int24", options: ServerOptions.new.numOutputBusChannels_(2), action: { 0.exit } )

~items = Array.fill(8, {
		x = 0.95.rrand(1.95);
		Pbindf(p, \delta, Pbrown(x, x+0.02, 0.01), \pan, -1.rrand(1.0), \amp, 0.2.exprand(1), \distance, 0.rrand(1.0), \bufRate, 1.rrand(2));
	});
Ppar(~items).play
)
//TESTING...
