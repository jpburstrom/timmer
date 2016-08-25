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
	snd = snd * EnvGen.ar(Env.perc(fadetime, 0.01, 1, -8));
	// snd = HPF.ar(snd, 200);

	snd = DynKlank.ar(`wood2, snd, \freq.kr(60), 0, sustain*3) * EnvGen.ar(Env.linen(0, sustain, 0.002), doneAction:2);
	Out.ar(0, Pan2.ar(snd.tanh, pan, amp));
}).add;


//Simple segment player
//startPos in seconds
SynthDef(\bufSegmentPlankS, { |out=0, bufnum=0, startPos=0, sustain=1, pan=0, amp=0|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
	snd = snd * EnvGen.ar(Env.perc(fadetime, 0.1, 1, -8)) * 0.8;
	// snd = HPF.ar(snd, 200);

	snd = DynKlank.ar(`wood2, snd, \freq.kr(60), 0, sustain*3) * EnvGen.ar(Env.linen(0, sustain, 0.002), doneAction:2);
	snd = snd.tanh;
	Out.ar(0, Balance2.ar(snd[0], snd[1], pan, amp));
}).add;

// Pbind(\dur, 0.2, \instrument, \plank, \sustain, 0.5).play


//A bell-like klank fx synth
SynthDef(\klankBell, { |inbus=0, outbus=0, freq=150, amp=1|

        var freqs = [1, 1.0019054878049, 1.7936737804878, 1.8009908536585, 2.5201981707317, 2.5224085365854, 2.9907012195122, 2.9940548780488, 3.7855182926829, 3.8061737804878, 4.5689024390244, 4.5754573170732, 5.0296493902439, 5.0455030487805, 6.0759908536585, 5.9094512195122, 6.4124237804878, 6.4430640243902, 7.0826219512195, 7.0923780487805, 7.3188262195122, 7.5551829268293] * 2;
        var amps = freqs.size.collect((_+1).reciprocal);
        var times = freqs.size.collect { Rand(1, 9.5) };
        var snd = DynKlank.ar(`[freqs, amps, times], In.ar(inbus, 2) * 0.01, freq * LFNoise2.kr(4).range(0.99, 1.01));
	Out.ar(outbus, snd * amp)
}).add;


//Temporary
SynthDef(\wood09, {
	var snd = In.ar(0, 2);
	var x;
	// snd = BPF.ar(snd, 88, 0.001);
	/*
	6.do {
	var drone = BPF.ar(snd, 88 * 0.95.rrand(1.06), 0.09);
	11.do { drone = AllpassN.ar(drone, 0.1, 0.001.rrand(0.005), 4) };
	snd =  snd + drone;

	};
	*/

	x = FreqShiftAA.ar(snd, -800);
	x = Klank.ar(`wood2, x * LFNoise2.ar(1).exprange(0.001, 2), 99, 0, 4) * 2;

	ReplaceOut.ar(0, x + snd);
}).add;

//Temporary
SynthDef(\resonator09, { |freq=88|
	var snd = In.ar(0, 2);
	snd = snd * EnvGen.ar(Env.asr(0.5, 1, 0.5), \gate.kr(0));
	snd = AllpassN.ar(BPF.ar(snd, freq, 0.1), 0.05, 88.reciprocal, 10) * \amp.kr(1);
	Out.ar(0, snd * 3);
}).add;