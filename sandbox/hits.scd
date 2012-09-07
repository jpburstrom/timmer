f = SoundFile.collectIntoBuffers("/Volumes/HD2/projects/timmer/samples/banks/hits/*")

SynthDef("timmer.hit", { arg bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02, outbus;
	var time, env, l, r;
	//pan.poll(Impulse.kr(10));
	time = BufDur.kr(bufnum) - attack - decay;
	#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0)
		* EnvGen.kr(Env.linen(attack, time , decay), doneAction: 2);
	OffsetOut.ar(outbus, Balance2.ar(l, r, pan, amp))
}).add;



Synth.new("timmer.hit", [\bufnum, f.choose()]);

(

Pbind(
	\instrument, "timmer.hit",
	// \amp, Pseq(BP(\q).d.swed019w).pow(2),
	\dur, 1/110,
	\amp, Pkey(\delta) * 3,
	\bufnum, Pslide(f.scramble(), inf, #[2,3], 2, 0),
	// \delta, Pslide(BP(\q).d.swed019w, inf, #[2,3], 2, 0) * 0.5,
	
	\legato, 1.1
	// \rate, Pwhite(0.95, 1.05, inf);
	).play
	
)

