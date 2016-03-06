(
Ndef(\fbtest, {
    var snd, amp;
    var in = LocalIn.ar(2);
    var freq = \freq.kr(100);
    amp = Amplitude.kr(in, 0.01, 0.2);
    snd = DelayC.ar(snd, 1, amp);
    snd = { CombL.ar(BPF.ar(Impulse.ar(0) + in, freq, 0.015), 0.2, (freq  + LFNoise2.kr(0.1, amp).range(freq * -0.1, freq * 0.1)).reciprocal, 1 - amp.lag(0.01)) }.dup;
    snd = Limiter.ar(LeakDC.ar(snd));
    LocalOut.ar(snd);
    snd * 0.2;
}).add
)

s.scope

