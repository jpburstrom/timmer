SynthDef(\resonator_03, {
    var freq= 84*2;
    var snd = BPF.ar(In.ar(\inbus.kr(0), 2) * 4, freq, LFNoise2.kr(0.1).range(0.002, 0.001)) * SinOsc.ar(LFNoise2.kr(0.2).exprange(120, 130));
    snd = CombC.ar(snd, 0.05, freq.reciprocal, 5);
    snd = DelayC.ar(snd, 0.1, LFNoise2.ar(0.2).range(0,0.01));
    snd = Decimator.ar(snd, 12000, 16);
    Out.ar(\outbus.kr(0), snd);
}).add