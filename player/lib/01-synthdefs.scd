var defaultFadeTime = 0.002;

Spec.add(\bufRate, \rate);
Spec.add(\dur, [0.001, 60, \exp]);
Spec.add(\delta, \dur);
Spec.add(\sustain, \dur);
Spec.add(\fqshift, [-20000, 20000]);
Spec.add(\startPos, [0, 1200]); //20 minutes
Spec.add(\attackStartPos, \startPos);
Spec.add(\legato, [0.001, 10, \exp]);
Spec.add(\outbus, \audiobus);
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
SynthDef(\bufSegment, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;

//A bufSegment with mid/side volume control
SynthDef(\bufSegmentMS, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
	#mid, side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1) * -3.dbamp, side * \sideAmp.kr(1) * -3.dbamp);
    OffsetOut.ar(outbus, snd * \amp.kr(1));
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
    OffsetOut.ar(\attackSendBus.kr(16), \attackSendAmp.kr * EnvGen.ar(Env.perc(0.002, \attackDecay.kr(0.03))) * attack);
	//output + envelope
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(\sendBus.kr(16), \sendAmp.kr(0, 0.1) * snd);
	OffsetOut.ar(\outbus.kr(0), snd * \amp.kr(1));
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

//Simple segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentFreqshift, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
	OffsetOut.ar(outbus, Balance2.ar(snd[0], snd[1], \pan.kr(0), \amp.kr(1)));
}).add;

//Simple segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentFreqshiftSmear, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, chains;

    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);

    snd = FreqShiftAA.ar(snd, \freqshift.kr(0));

    chains = FFT({LocalBuf(2048)}.dup, snd);
    chains = PV_MagSmear(chains, \smear.kr(0));
    snd = IFFT(chains);

    snd = snd * EnvGen.ar(Env([0, 0, 1, 1, 0], [2048 / SampleRate.ir ,fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, Balance2.ar(snd[0], snd[1], \pan.kr(0), \amp.kr(1)));
}).add;


//Simple segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentFreqshiftMS, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side;
    var flutter = 2.pow(LFNoise2.ar(\flutterSpeed.kr(0.1), \flutterDepth.kr(0)));
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1) * flutter, 1, startPos);
    snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    #mid, side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1), side * \sideAmp.kr(1));
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;


//ADSR segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentASRFreqshiftMS, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side;
    var flutter = 2.pow(LFNoise2.ar(\flutterSpeed.kr(0.1), \flutterDepth.kr(0)));
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1) * flutter, 1, startPos);
    snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    snd = snd * EnvGen.ar(Env.asr(\attack.kr(0.01),\susLevel.kr(1), \release.kr(1), 1, -10), \gate.kr(1), doneAction:2);
    #mid, side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1), side * \sideAmp.kr(1));
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;

//Simple segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentFreqshiftMS, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side;
    var flutter = 2.pow(LFNoise2.ar(\flutterSpeed.kr(0.1), \flutterDepth.kr(0)));
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1) * flutter, 1, startPos);
    snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    #mid, side = Fdef(\stereo2ms).value(snd);
	snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1), side * \sideAmp.kr(1));
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;


//Simple segment player with freqshift
//startPos in seconds
SynthDef(\bufSegmentFreqSplitShiftMS, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd, mid, side, lop;
    var flutter = 2.pow(LFNoise2.ar(\flutterSpeed.kr(0.1), \flutterDepth.kr(0)));
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1) * flutter, 1, startPos);
    lop = LPF.ar(snd, \ffreq.kr(440));
    snd = FreqShiftAA.ar(snd - lop, \freqshift.kr(0), 1, \freqshiftAmp.kr(1));
    #mid, side = Fdef(\stereo2ms).value(snd);
    snd = Fdef(\ms2stereo).value(mid * \midAmp.kr(1), side * \sideAmp.kr(1));
    snd = lop + snd;
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;


//Debug tick
SynthDef(\tick, {
    Line.kr(0, 1, 0.1, doneAction:2);
    Out.ar(\outbus.kr(0), Impulse.ar(0).dup);
}).add;


SynthDef(\sinewave, {
    var snd = SinOsc.ar(\freq.kr(440), 0, \amp.kr(0.1));
    snd = snd * EnvGen.ar(Env.asr(\attack.kr(0.01), \susLevel.kr(1), \release.kr(1)), \gate.kr(1), doneAction:2);
    Out.ar(\outbus.kr(0), Pan2.ar(snd, \pan.kr(0)));
}).add;