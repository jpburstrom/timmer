var defaultFadeTime = 0.002;
var wood2 = [[1.0, 1.777, 2.378, 3.377],		// Wood2
	[0.04, 0.01, 0.01, 0.008],
	[0.2, 0.15, 0.15, 0.3]];


SynthDef(\plank, { |freq, amp=1, sustain=0.1, pan=0|
	//This excitation doesn't sound very good
	var snd = Decay.ar(Impulse.ar(0), 0.1, 0.1) + (PinkNoise.ar(1) * EnvGen.ar(Env.perc(0.002, 0.005, 1, -8)) * 0.8);

	snd = DynKlank.ar(`wood2, snd, 60, 0, sustain*3) * EnvGen.ar(Env.linen(0, sustain, 0.002), doneAction:2);
	Out.ar(0, Pan2.ar(snd.tanh, pan, amp));
}).add;



//Simple segment player
//startPos in seconds
SynthDef(\bufSegmentPlank, { |out=0, bufnum=0, startPos=0, sustain=1, pan=0, amp=0|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos).sum;
	snd = snd * EnvGen.ar(Env.perc(0.002, 0.005, 1, -8)) * 0.8;

	snd = DynKlank.ar(`wood2, snd, 60, 0, sustain*3) * EnvGen.ar(Env.linen(0, sustain, 0.002), doneAction:2);
	Out.ar(0, Pan2.ar(snd.tanh, pan, amp));
}).add;


//Simple segment player
//startPos in seconds
SynthDef(\bufSegmentPlankS, { |out=0, bufnum=0, startPos=0, sustain=1, pan=0, amp=0|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
	snd = snd * EnvGen.ar(Env.perc(0.002, 0.005, 1, -8)) * 0.8;

	snd = DynKlank.ar(`wood2, snd, 60, 0, sustain*3) * EnvGen.ar(Env.linen(0, sustain, 0.002), doneAction:2);
	snd = snd.tanh;
	Out.ar(0, Balance2.ar(snd[0], snd[1], pan, amp));
}).add;

// Pbind(\dur, 0.2, \instrument, \plank, \sustain, 0.5).play
