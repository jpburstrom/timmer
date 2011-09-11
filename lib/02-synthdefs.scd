//Timmer.grain1 - basic stereo single-grain player.
SynthDef("timmer.grain1", { arg start, time, bufnum, rate = 1, pan = 0, amp = 1, attack = 0.001, decay = 0.02, outbus;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	start = start - (attack * SampleRate.ir);	
	#l, r = PlayBuf.ar(2, bufnum, rate * BufRateScale.kr(bufnum), 1, start, 0)
		* EnvGen.kr(Env.linen(attack, time, decay), doneAction: 2);
	OffsetOut.ar(outbus, Balance2.ar(l, r, pan, amp))
}).add;

/*
Pbind(
	\instrument, "timmer.grain1",
	\start, Pwhite(0, 44100),
	\bufnum, 3,
	\time, 2,
	\dur, 0.1,
	\db, Pwhite(-20, -3),
	\pan, Pwhite(0.97, 1)
).play
*/



