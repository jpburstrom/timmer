(
Ndef(\bpFreqShift, {
    arg freq = 440, shift=0.5;

    var snd = PlayBuf.ar(2, ~buf).sum;
    // in = HPF.ar(in, 100);
    var bp = BPF.ar(snd, freq, \rq.kr(0.02));
    snd = snd - bp;

    bp = FreqShiftAA.ar(bp, (freq * shift) - freq);
    bp = bp * \ampx4.kr(1);

    // bp = Balance.ar(bp, snd);

    SelectX.ar(\unipolar.kr, [bp, snd]).dup

}).addSpec(\shift, \rate.asSpec).mold.play
)
