b = Buffer.read(s, "/Volumes/HD2/projects/timmer/render/to SC/single-note-arco.wav");

SynthDef("timmer.sampleNote", { 
	arg out=0, bufnum=0, amp=1, pan=0, freq=440, startPos=0, attack=0.1, release=0.1, sustain=1;

	var sound;
	sustain = (sustain - attack).max(0.01); //subtract AD, for Env
	freq = freq/440; //Convert to ratio

	//chain = PV_RandComb(chain, EnvGen.kr(Env([0,1], [sustain+release], curve: -3)));
	//chain = PV_MaxMagN(chain, EnvGen.kr(Env([4096, 10], [sustain+release], curve: 5)));
	sound = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * freq, startPos: BufFrames.kr(bufnum) * startPos) *  EnvGen.ar(Env.linen(attack, sustain, release, curve:-2), doneAction:2); 
	Out.ar(out, Pan2.ar(sound, pan, amp));
}).add;

Pdef(\test2, 
	Pchain(
		Pbind( \out, 2, \instrument, 'timmer.sampleNote', \bufnum, b, \amp, Pbrown(0.7,1), \dur, 1, \legato, 0.5, \release, 1, \attack, 0.01, \octave, 5, \startPos, Pwhite(0, 0.5)),
		Pbind(\dur, 7, \note, Pslide([0,1,3,4,6,7,9,10],inf, Pwhite(1,3), Pxrand([-3,-2,-1,1,2], inf)))
		))

MIDIdef.noteOn(\sampleNote, { arg ... args;
	(instrument: 'timmer.sampleNote', dur: 3, amp:1, bufnum: b, midinote: args[1]).play;
});

(instrument: 'timmer.sampleNote', bufnum: b, midinote: 54, amp:1).play;
