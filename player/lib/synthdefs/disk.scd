var defaultFadeTime = 0.002;

//Simple segment player
SynthDef(\diskSegment, { |outbus(0), bufnum(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    snd = DiskIn.ar(2, bufnum);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;

//Simple segment player
SynthDef(\diskSegment_3ch, { |outbus(0), bufnum(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    snd = DiskIn.ar(3, bufnum);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;