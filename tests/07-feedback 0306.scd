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
    var freq = \freq.kr(99) * [1,3,4.8,5.5,6];
    // var freq = \freq.kr(99) * [0.5, 1, 3];

    //Allpass durs
    var comblen = 8.collect(_.nthPrime.reciprocal);
    //Reciprocal of freq
	var delay1 = freq.reciprocal - ControlDur.ir;



	in1 = snd = In.ar(0, 2);

    //Analyse amplitude from input, delayed with a randomish amount
    amp = Amplitude.kr(DelayC.ar(snd, 1, LFNoise2.ar(1).range(0.02, 0.3)), 3, 8);


    in1 = LocalIn.ar(8) + in1;
    in1 = DelayC.ar(in1 * -1, 0.05, delay1 + PinkNoise.ar(delay1 * 0.05));
    in1 = AllpassC.ar(in1, 1, comblen, LFNoise1.ar(0.2).range(2, 10), 0.7);


    in1 = BHiShelf.ar(in1, 800, 1, LFNoise2.ar(0.3).range(-0.5, 0.5));
	// in1 = Compander.ar(in1, in1, 0.9, 1, 0.1, 0.1, 0.1);

    //LFNoise2 range decides feedback. seems to need ~1.5 to start self-oscillating (softclip?)
    in1 = LeakDC.ar(in1.softclip * { LFNoise2.ar(0.3).range(0.99, 1.9) }.dup(8));

	// in1 = LPF.ar(in1, freq);
	LocalOut.ar(in1);

    in1 = RLPF.ar(in1, LFNoise2.kr(0.1).exprange(750, 1000), 0.5);

    //Switch center position on every note offset
    // in1 = Splay.ar(in1, 0.02, 1, TRand.kr(-1, 1, amp[0] < 0.002).lag(0.005));

    in1 = Splay.ar(in1, 0.2, 1);


    in1 = Limiter.ar(in1);

	// snd = in1 * 0.1;
    snd = in1 * Fdef(\autoscale).value(amp, 0, 3, 0, 0.3).lag(0.2);
    // in1 = LPF.ar(in1, 480);

    //One last comb filter
    snd = snd - Splay.ar(LPF.ar(CombC.ar(snd, 0.1, delay1, 3.9, 0.3), 1000));

	// MS -> stereo
	// snd = Fdef(\ms2stereo).value(snd[0] * 0.dbamp, snd[1] * 3);

	Out.ar(0, snd * -32.dbamp);

}).play
)

Ndef(\fbtest2).end
