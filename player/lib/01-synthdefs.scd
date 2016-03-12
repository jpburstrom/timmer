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


