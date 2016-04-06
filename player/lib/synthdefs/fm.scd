SynthDef(\fmGloss, {
	var amp1 = EnvGen.kr(Env.perc(0.01, \sustain.kr(1)), doneAction:2);
	var amp2 = EnvGen.kr(Env([1, 0.15, 0], [0.2, 3], -4));
	var ratios = [1.0020, 1.0020, 1.0020, 0.9980, 19.000, 1.000];
	var offset = [0,0,0,-0.20,0,0]; //Hz
	var mm = [
		[ 0.12, 0, 0, 0, 0, 0 ],
		[ 0.54, 0, 0, 0, 0, 0 ],
		[ 0, 0, 0.11, 0, 0, 0 ],
		[ 0, 0, 0.71, 0, 0, 0 ],
		[ 0, 0, 0, 0, 0.25, 0 ],
		[ 0, 0, 0, 0, 0.56, 0 ]
	];

	var ctl = [
		(ratios * \freq.ir(440)) + offset,
		0 ! 6,
		[amp1, amp1, amp1, amp1, amp2, amp1]
	].flop;

	var snd = FM7.ar(ctl, mm);


	snd[5] = snd[5] * 0.707;

	snd = [snd[1] + snd[5], snd[3] + snd[5]];

	Out.ar(\out.kr(0), snd * 0.05 * \amp.kr(1));
}).add;
