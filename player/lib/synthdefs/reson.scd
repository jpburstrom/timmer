SynthDef(\resonate, { | inbus=0, outbus=0, freq=440 |
    var snd = In.ar(inbus, 2);
    snd = Resonz.ar(snd, freq, 0.001, 20);
    snd = snd * EnvGen.ar(Env.asr(\attack.kr(1), \amp.kr(1), \release.kr(1)), \gate.kr(1), doneAction:2);
    Out.ar(outbus, snd);
}).add;


SynthDef(\resonate_08, { |inbus=0, outbus=0|
    //G1.namecps
    var freq = 97.998858995437 * 5;
    var snd = In.ar(inbus, 2);
    var detune = 0.2;
    //detune 1
    var lo = detune.neg.midiratio ;
    var hi = detune.midiratio ;
    var bp = (Resonz.ar(snd, freq * LFNoise2.kr(0.1).range(lo, hi), LFNoise2.kr(0.2).range(0.001, 0.01), 1));
    //Detune 2
    snd = FreqShift.ar(bp, LFNoise2.ar(0.1).range(-10, 10), mul:1);
    //Out.ar(sendbus, snd); //Send to convo rev
    Out.ar(outbus, snd);
    // ReplaceOut.ar(0, snd);
}).add;
