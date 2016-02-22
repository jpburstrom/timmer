~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);

//TODO: simplify and launch one of these synths per onset, with possibility to change resonant frequency
//

(
Ndef(\test2, {
    var freq = "d1".namecps;
    var snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);
    var bp = BPF.ar(snd, freq, 0.01);
	snd = snd - bp;
	//Gate main signal from
	bp = Compander.ar(Mix(snd).dup, bp, 0.001, 10, 0.01, 0.01, 0.01);
	bp = CombC.ar(bp, 0.2, freq.reciprocal, LFNoise2.ar(2).range(1, 5), -1);

	bp = RLPFD.ar(bp, freq * Demand.ar(Impulse.ar(0) + Dust.ar(0.1), 0, Dxrand((2..8), inf)).poll.lag(0.1), 0.8, 0.4) * 0.1;
	bp = bp * -1; //SelectX.ar(MouseX.kr, [bp, ~ezConv.ar(bp, 0, mul:0.1)]);

	bp ;
}).play
)
