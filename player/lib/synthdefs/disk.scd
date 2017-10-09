(
~wrap = Proto({

    ~diskIn = { |ch=2, bufnum=0|
        DiskIn.ar(ch, bufnum);
    };

    ~vDiskIn = { |ch=2, bufnum=0, rate=1|
        VDiskIn.ar(ch, bufnum, rate);
    };

    ~fadeInOut = { |snd, fadetime=0.002, sustain=1|
        sustain = sustain - fadetime; //ok?
        snd * Env([0, 1, 1, 0], [fadetime, sustain, fadetime]).ar(2);
    };

    ~adjustMS = { |snd|
        var mid, side;
        #mid, side = Fdef(\stereo2ms).value(snd);
        Fdef(\ms2stereo).value(mid * \midAmp.kr(1) * -3.dbamp, side * \sideAmp.kr(1) * -3.dbamp);
    };

    ~freqShift = { |snd|
        snd = FreqShiftAA.ar(snd, \freqshift.kr(0));
    };


    ~out = { |snd, outbus=0|
        OffsetOut.ar(outbus, snd * \amp.kr(1));
    };


    currentEnvironment.env.keysValuesDo { |k, func|
        currentEnvironment[k] = "{ |... args| SynthDef.wrap(%, nil, args) }".format(func.asCompileString).interpret
    };


});
);

//Create versions for 2 and 3 channels

//Simple segment player
//bufnum fadetime sustain outbus
SynthDef(\diskSegment, {
    var snd = ~wrap.diskIn(2);
    snd = ~wrap.fadeInOut(snd);
    ~wrap.out(snd);
}).add;

//Simple segment player, 3ch version
//bufnum fadetime sustain outbus
SynthDef(\diskSegment_3ch, {
    var snd = ~wrap.diskIn(3);
    snd = ~wrap.fadeInOut(snd);
    ~wrap.out(snd);
}).add;


//TODO: port below to disk

//A bufSegment with mid/side volume control
//bufnum fadetime sustain midAmp sideAmp outbus
SynthDef(\diskSegmentMS, {
	 var snd = ~wrap.diskIn(2);
    snd = ~wrap.fadeInOut(snd);
    snd = ~wrap.adjustMS(snd);
    ~wrap.out(snd);
}).add;


//Simple segment player with freqshift
//startPos in seconds
//bufnum fadetime sustain freqshift outbus
SynthDef(\diskSegmentFreqshift, {
    var snd = ~wrap.diskIn(2);
    snd = ~wrap.fadeInOut(snd);
    snd = ~wrap.freqShift(snd);
    ~wrap.out(snd);
}).add;

//Simple segment player with freqshift, 3-channel
//bufnum fadetime sustain freqshift outbus
SynthDef(\diskSegmentFreqshift_3ch, {
    var snd = ~wrap.diskIn(3);
    snd = ~wrap.fadeInOut(snd);
    snd = ~wrap.freqShift(snd);
    ~wrap.out(snd);
}).add;

//Simple segment player with freqshift
//startPos in seconds
//bufnum fadetime sustain freqshift smear outbus
SynthDef(\diskSegmentFreqshiftSmear, { arg fadetime=0.002, sustain=1;
    var chains;

    var snd = ~wrap.diskIn(2);
    snd = ~wrap.freqShift(snd);

    chains = FFT({LocalBuf(2048)}.dup, snd);
    chains = PV_MagSmear(chains, \smear.kr(0));
    snd = IFFT(chains);
    sustain = sustain - fadetime; //Make last fade stop at sustain end

    snd = snd * Env([0, 0, 1, 1, 0], [2048 / SampleRate.ir ,fadetime, sustain, fadetime]).ar(2);

    ~wrap.out(snd);

}).add;

//Simple segment player with freqshift
//startPos in seconds
SynthDef(\diskSegmentFreqSplitShiftMS, { arg bufnum=0, bufRate=1;
    var snd, mid, side, lop;
    var flutter = 2.pow(LFNoise2.ar(\flutterSpeed.kr(0.1), \flutterDepth.kr(0)));
    snd = ~wrap.vDiskIn(2, bufnum, bufRate * flutter);
    lop = LPF.ar(snd, \ffreq.kr(440));
    snd = ~wrap.freqShift(snd - lop) * \freqshiftAmp.kr(1);
    snd = ~wrap.adjustMS(snd);
    snd = lop + snd;
    snd = ~wrap.fadeInOut(snd);
    ~wrap.out(snd);
}).add;

//Segment player with separate attack send
//Special version for 3 channel file (stereo + extra mono track)
//Sending stereo to send and outputs extra mono
SynthDef(\diskSegmentAttackSend_01, {
    var snd, snd_mono;
	var attackDur = \attackDur.kr(0.06); //Duration of attack part

    snd = ~wrap.diskIn(2);

    //snd_mono = snd[2];
    //snd = snd[..1];

    OffsetOut.ar(\attackSendBus.kr(16), \attackSendAmp.kr * EnvGen.ar(Env.perc(0.002, \attackDecay.kr(0.03))) * snd);

	//output + envelope
    snd = ~wrap.fadeInOut(snd);

    ~wrap.out(snd, \sendBus.kr(16), \sendAmp.kr(0, 0.1));
    ~wrap.out(snd);
}).add;


SynthDef(\diskSegmentResonance, {

    var snd = ~wrap.vDiskIn(2);

    snd = RLPF.ar(PinkNoise.ar * FreqShiftAA.ar(snd, \freq.kr(440).neg), \freq.kr, 0.01);
    snd = ~wrap.fadeInOut(snd.tanh);

    ~wrap.out(snd);

}).add;

SynthDef(\diskSegmentResonance_3ch, {

    var snd = ~wrap.vDiskIn(3);

    snd = RLPF.ar(PinkNoise.ar * FreqShiftAA.ar(snd, \freq.kr(440).neg), \freq.kr, 0.01);
    snd = ~wrap.fadeInOut(snd.tanh);

    ~wrap.out(snd);

}).add;