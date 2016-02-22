~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);

(
Ndef(\test2, {
    var freq = "d3".namecps;
    var snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);
    var bp = BPF.ar(snd, freq, 0.01);
    snd = snd - bp;
    bp = Compander.ar(bp, bp, 0.005, 10, 0.01, 0.01, 0.01).poll;
    bp = CombC.ar(bp, 0.2, freq.reciprocal, 1.2, -1);
    snd + bp
}).play
)

Ndef(\test).clear

x = { SinOsc.ar("D3".namecps) * 0.1 }.play
x.free

"D2".namecps