(
Ndef(\fbtest, {
    var snd, amp;
    var in = LocalIn.ar(2);
    var freq = \freq.kr(100);

    amp = Amplitude.kr(in, 0.01, 0.2);
	snd = DelayC.ar(snd, 1, amp); //hmm this doesn't do anything?
    snd = { CombL.ar(BPF.ar(Impulse.ar(0) + in, freq, 0.015), 0.2, (freq  + LFNoise2.kr(0.1, amp).range(freq * -0.1, freq * 0.1)).reciprocal, 1 - amp.lag(0.01)) }.dup;
    snd = Limiter.ar(LeakDC.ar(snd));
    LocalOut.ar(snd);
    snd * 0.2;
}).add
)


(
Ndef(\fbtest2, {
    var snd, amp, in1, in2;
	// var mid, side;
	var freq = \freq.kr(99) * (1.00, 1.01 .. 1.08);
	var delay1;
	// freq = LFNoise2.kr(1).exprange(98, 100) -  ControlDur.ir.poll;
	delay1 = freq.reciprocal - ControlDur.ir;

	snd = In.ar(0, 2);


	//Stereo -> MS
	// snd = Fdef(\stereo2ms).value(snd);

	snd = 4.collect{snd}.flat;

	in1 = (Line.ar * LocalIn.ar(8)) + snd;

	// in1 = in1.swap(0,1);

	// LFNoise0

	// NaN warning
	// comblen = LFNoise2.ar(SinOsc.ar(LFNoise1.ar(0.05).range(0.1,0.6)).range(0.1,0.3)).range(0.01, 1).lag(0.01).poll;

	in1 = in1 + in1.collect { |x, i|
		var comblen = LFNoise1.ar(LFNoise1.ar(0.1).range(0.05, 0.5)).range(0.1, 0.5).lag(2);
		//This is the 'comb filter'
		DelayC.ar(x,  0.05, delay1[i]);
		AllpassC.ar(x, 1, comblen, -1, 0.7)
	};

	//TODO: remove this
	in1 = Fdef(\checkBad).value(in1, 0);

	in1 = BHiShelf.ar(in1, 1000, 1, -1);
	// in1 = Compander.ar(in1, in1, 0.9, 1, 0.1, 0.1, 0.1);

	in1 = LeakDC.ar(in1.softclip * LFNoise2.ar(1).range(0.7, 1.3));

	// in1 = LPF.ar(in1, freq);
	LocalOut.ar(in1);

	in1 = RLPF.ar(in1, LFNoise2.kr(0.1).exprange(750, 3000), 0.01);

	in1 = Splay.ar(in1);

	// in1 = LPF.ar(in1, 480);
	in1 = Limiter.ar(in1);


	// snd = in1 * 0.1;
	snd = in1 * RedAutoScale.kr(Amplitude.kr(snd, 0.1, 8), 0, 3, 0, 0.3).lag(0.2);




	// MS -> stereo
	// snd = Fdef(\ms2stereo).value(snd[0] * 0.dbamp, snd[1] * 3);

	Out.ar(2, snd * -36.dbamp);

}).play
)
