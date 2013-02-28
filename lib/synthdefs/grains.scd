//---Snickarglädje
SynthDef(\klanky, { |freq=440, sustain=1, bufnum=0, amp=0.6|
    var snd = PlayBuf.ar(2, bufnum) * EnvGen.ar(Env.perc(0, sustain, amp, 0), doneAction:2);
    snd = (Klank.ar(`[[1, 1.97,3.34,5], [2,2,4,0.2].normalizeSum, [0.3,1.2,0.1,1.3]], snd, freq, 0, sustain) * 0.2);
    // snd = snd * EnvGen.kr(Env([0,1,1], [0, sustain]), doneAction:2);
    Out.ar(0, snd);
}).add;
