var defaultFadeTime = 0.002;

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


//Simple segment player
//startPos in seconds
SynthDef(\bufSegment_3ch, { |outbus(0), outbus_mono(2), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(defaultFadeTime);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(3, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(outbus, snd[..1] * \amp.kr(1));
    OffsetOut.ar(outbus_mono, snd[2] * \amp.kr(1));
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

//Segment player with separate attack and sustain startPos's
//Special version for 3 channel file (stereo + extra mono track)
//Sending stereo to send and outputs extra mono
SynthDef(\bufSegmentAttackSend_01, { |bufnum, startPos, attackStartPos, sustain=0, bufRate=1, attackPitchDev=0|
    var snd, attack, snd_mono;
	var fadetime = \fadetime.kr(defaultFadeTime);
	var attackDur = \attackDur.kr(0.06); //Duration of attack part

	//Different positions for attack and sustain parts
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples
	attackStartPos = ((attackStartPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples

	//Randomize attack pitch
	attack = PlayBuf.ar(3, bufnum,
        BufRateScale.kr(bufnum) * bufRate
        * LFNoise2.kr(Rand(1,5)).range((-10 * attackPitchDev).midiratio, (1 * attackPitchDev).midiratio), startPos: attackStartPos)[..1];

    //release part is left blank
    snd = PlayBuf.ar(3, bufnum, BufRateScale.kr(bufnum) * bufRate, startPos: startPos);
    snd_mono = snd[2];
    snd = snd[..1];

    OffsetOut.ar(\attackSendBus.kr(16), \attackSendAmp.kr * EnvGen.ar(Env.perc(0.002, \attackDecay.kr(0.03))) * attack);
	//output + envelope
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(\sendBus.kr(16), \sendAmp.kr(0, 0.1) * snd);
	OffsetOut.ar(\outbus.kr(0), snd * \amp.kr(1));
    OffsetOut.ar(\outbus_mono.kr(2), snd_mono * \amp.kr(1));
}).add;

//Buffer segment with decaying + filtered comb filter
SynthDef(\bufSegmentComb, { |outbus(0), bufnum(0), startPos(0), sustain(1)|
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


	OffsetOut.ar(outbus, snd * \amp.kr(1));


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

SynthDef(\bufSegmentResonance, {|outbus(0), bufnum(0), startPos(0), sustain(1)|
	var fadetime = \fadetime.kr(0.002);
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = RLPF.ar(PinkNoise.ar * FreqShiftAA.ar(snd, \freq.kr(440).neg), \freq.kr, 0.01);
    snd = snd.tanh * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);



    OffsetOut.ar(outbus, snd * \amp.kr(1));
}).add;