var defaultFadeTime = 0.002;

Spec.add(\bufRate, \rate);
Spec.add(\dur, [0.001, 60, \exp]);
Spec.add(\delta, \dur);
Spec.add(\sustain, \dur);
Spec.add(\fqshift, [-20000, 20000]);
Spec.add(\startPos, [0, 1200]); //20 minutes
Spec.add(\attackStartPos, \startPos);
Spec.add(\legato, [0.001, 10, \exp]);
Spec.add(\out, \audiobus);
Spec.add(\sendAmp, \amp);
Spec.add(\midAmp, \amp);
Spec.add(\sideAmp, \amp);

//--pattern-specific specs--//
Spec.add(\quantAmt, \unipolar);
Spec.add(\varFactor, \unipolar);

//Load all files in synthdefs/
"synthdefs/*.scd".resolveRelative.loadPaths;

//Simple segment player
//startPos in seconds
SynthDef(\bufSegment, { |out(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(out, snd * \amp.kr(1));
}).add;

//A bufSegment with mid/side volume control
SynthDef(\bufSegmentMS, { |out(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
	#mid, side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1), side * \sideAmp.kr(1));
    OffsetOut.ar(out, snd * \amp.kr(1));
}).add;

//Segment player with separate attack and sustain startPos's
SynthDef(\bufSegmentAttackSend, { |bufnum, startPos, attackStartPos, sustain=0, bufRate=1, varFactor=0|
    var snd, attack, release;
	var fadetime = \fadetime.kr(defaultFadeTime);
	var attackDur = \attackDur.kr(0.06); //Duration of attack part

	//Different positions for attack and sustain parts
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples
	attackStartPos = ((attackStartPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples

	//Randomize attack pitch
	attack = PlayBuf.ar(2, bufnum,
        BufRateScale.kr(bufnum) * bufRate
        * LFNoise2.kr(Rand(1,5)).range((-10 * varFactor).midiratio, (1 * varFactor).midiratio), startPos: attackStartPos);


	//release part is left blank
    snd = release = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * bufRate, startPos: startPos);
    attack = snd;

    //mix attack and release
	snd = LinSelectX.ar(1, [snd, LinSelectX.ar(Line.ar(0, 1, attackDur), [attack, release])]);
    OffsetOut.ar(\attackSendBus.kr(16), \attackSendAmp.kr * EnvGen.ar(Env.perc(0.002, 0.03)) * attack);
	//output + envelope
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(\sendBus.kr(16), \sendAmp.kr(0, 0.1) * snd);
	OffsetOut.ar(\out.kr(0), snd * \amp.kr(1));
}).add;

//Buffer segment with decaying + filtered comb filter
SynthDef(\bufSegmentComb, { |out(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
	var atk, snd;
	startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
	snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
	snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]));

	//Add comb filter and filter it
	//Linear interpolation is nice
	atk = CombC.ar(snd, 0.2, \freq.kr(440).reciprocal,  \combDecay.kr(4) - (LFNoise2.ar(\combDecayDevSpd.kr(2)).range(0, \combDecay.kr) * \combDecayDev.kr(0)));
	atk = RLPFD.ar(atk, \ffreq.kr(1000), \fres.kr(0.6), \fdist.kr(0.3));
	atk = atk * EnvGen.ar(Env.linen(\combAttack.kr(2), 0.1, \combDecay.kr - \combAttack.kr, [4, 0, -4]), doneAction:2);

	atk = atk * 0.1;

	snd = XFade2.ar(snd, atk, \mix.kr(0));


	OffsetOut.ar(out, snd * \amp.kr(1));


}).add;


//Debug tick
SynthDef(\tick, {
    Line.kr(0, 1, 0.1, doneAction:2);
    Out.ar(\out.kr(0), Impulse.ar(0).dup);
}).add;


//## 07 -- feedback synth ##//

SynthDef(\feedback_07, { |outbus=0|
    var snd, amp, in1, in2;
	// var mid, side;
	var freq = NamedControl.kr(\partials, #[81,99,242,404,81,99,242,404], 1);
    // var freq = \freq.kr(99) * [0.5, 1, 3];

    //Allpass durs
    var comblen = 8.collect(_.nthPrime.reciprocal);
    //Reciprocal of freq
    var delay1 = (freq.reciprocal - ControlDur.ir).max(0);

	in1 = snd = In.ar(outbus, 2) * \inAmp.kr(1, 0.1);

    //Analyse amplitude from input, delayed with a randomish amount
	amp = Amplitude.kr(DelayC.ar(snd, 1, LFNoise2.ar(1).range(0.02, 0.3)), 0.1, 0.1).lagud(8,8);

	//**Feedback loop start**
    in1 = LocalIn.ar(8) + in1;
    in1 = DelayC.ar(in1 * -1, 0.05, delay1 + PinkNoise.ar(delay1 * 0.05));
    in1 = AllpassC.ar(in1, 1, comblen, LFNoise1.ar(0.2).range(2, 10), 0.7);


    in1 = BHiShelf.ar(in1, 800, 1, LFNoise2.ar(0.3).range(-0.5, 1.5));

	//LFNoise2 range decides feedback. seems to need ~1.5 to start self-oscillating (softclip?)
	in1 = LeakDC.ar(in1.softclip * { LFNoise2.ar(0.3).range(\minFeedback.kr(0.59, 3), \maxFeedback.kr(2.9, 3)) }.dup(8));

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
    snd = snd - Splay.ar(LPF.ar(CombC.ar(snd, 0.1, delay1.scramble, 3.9, 0.3), 1000));
	in1 = Limiter.ar(in1);

	snd = EnvGen.ar(Env.asr(\attackTime.kr(1), 1, \releaseTime.kr(1)), \gate.kr(1), \amp.kr(-32.dbamp), doneAction:2) * snd;

	Out.ar(outbus, snd);

}).add
