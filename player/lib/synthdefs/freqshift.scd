SynthDef(\freqShift, { |inbus, outbus, amp=1, midAmp=1, sideAmp=1|
    var mid, side;
    var snd = FreqShiftAA.ar(In.ar(inbus, 2), \freq.kr(-100, 0.05));
    #mid,side = Fdef(\stereo2ms).value(snd);
    snd = Fdef(\ms2stereo).value(mid*midAmp, side*sideAmp);
    // Amplitude.kr(snd, 2, 2)./*poll*/;
    Out.ar(outbus, snd * amp);
}).add;

SynthDef(\freqShiftWeird_02, { |inbus=0, outbus=0|
    var snd = In.ar(inbus, 2);

    //A slow random delay up to 15 ms -- before where you start to distinguish it
    //as a separate sound. LFNoise is clipped below 0, so ~ half of the time there's no delay
    snd = DelayC.ar(snd, 0.015, LFNoise2.ar(1, 0.015).max(0));

    snd = Fdef(\stereo2ms).value(snd);

    snd = FreqShiftAA.ar(snd, LFNoise2.kr(LFNoise1.kr(0.1).range(0.01, 0.3)).range(-600, -1000));
    snd[0] = snd[0] * 0.667;
    snd[1] = snd[1] * 1.5;

    snd = BHiShelf.ar(snd, 4700, 2, -10);

    snd = Fdef(\ms2stereo).value(*snd);

    snd = snd * LFNoise2.kr(2).exprange(0.5, 5);

    Out.ar(outbus, snd); //Parallel

}).add;