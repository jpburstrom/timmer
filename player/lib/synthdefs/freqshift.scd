SynthDef(\freqShift, { |inbus, outbus, amp=1, midAmp=1, sideAmp=1|
	var mid, side;
	var snd = FreqShiftAA.ar(In.ar(inbus, 2), \freq.kr(-100, 0.05));
	#mid,side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid*midAmp, side*sideAmp);
	// Amplitude.kr(snd, 2, 2)./*poll*/;
	Out.ar(0, snd * amp);
}).add;