
//## 07 -- feedback synth ##//

SynthDef(\feedback_07, { |outbus=0|
    var snd, amp, in1, in2;
	// var mid, side;
	var freq = NamedControl.kr(\partials, #[99,242,404], 1);
    // var freq = \freq.kr(99) * [0.5, 1, 3];

    //Allpass durs
    var comblen = freq.size.collect(_.nthPrime.reciprocal);
    //Reciprocal of freq
    var delay1 = (freq.reciprocal - ControlDur.ir).max(0);

	in1 = snd = In.ar(outbus, 2) * \inAmp.kr(1, 0.1);

    //Analyse amplitude from input, delayed with a randomish amount
	amp = Amplitude.kr(DelayC.ar(snd, 1, LFNoise2.ar(1).range(0.02, 0.3)), 0.1, 0.1).lagud(8,8);

	//**Feedback loop start**
    in1 = LocalIn.ar(freq.size) + in1;
    in1 = DelayC.ar(in1 * -1, 0.05, delay1 + PinkNoise.ar(delay1 * 0.1));
    in1 = AllpassC.ar(in1, 1, comblen, LFNoise1.ar(0.2).range(0.1, 0.9), 0.7);


    in1 = BHiShelf.ar(in1, 800, 1, LFNoise2.ar(0.3).range(-0.5, 4.5));

	//LFNoise2 range decides feedback. seems to need ~1.5 to start self-oscillating (softclip?)
	in1 = LeakDC.ar(in1.softclip * { LFNoise2.ar(0.3).range(\minFeedback.kr(0.9, 3), \maxFeedback.kr(3.99, 3)) }.dup(freq.size));

	//**Feedback loop end**
	LocalOut.ar(in1 + (in1.sum * \leak.kr(0.1, 1)));

	//Filtering
	in1 = RLPF.ar(in1, LFNoise2.kr(0.1).exprange(750, 2000), 0.5);

	//narrow it down
    in1 = Splay.ar(in1, 0.2, 1);

	// snd = in1 * 0.1;
	snd = SelectX.ar(\ampAutoscale.kr(1, 2), [in1, in1 * Fdef(\autoscale).value(amp, 0, 3, 0, 0.3).lag(0.2)]);
    // in1 = LPF.ar(in1, 480);

    //One last comb filter
    snd = snd + Splay.ar(LPF.ar(CombC.ar(snd, 0.1, delay1.scramble, 3.9, 0.3), 1000));
	in1 = Limiter.ar(in1);

	snd = EnvGen.ar(Env.asr(\attackTime.kr(1), 1, \releaseTime.kr(1)), \gate.kr(1), \amp.kr(-32.dbamp), doneAction:2) * snd;

	Out.ar(outbus, snd);

}).add