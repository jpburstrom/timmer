SynthDef(\freqShift, { |inbus, outbus, amp|
	var snd = FreqShiftAA.ar(In.ar(inbus, 2), \freq.kr(-100, 0.05));
	Out.ar(outbus, snd * amp);
}).add;