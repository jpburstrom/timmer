~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);

(
Ndef(\combTest, {
    var freq = "d1".namecps;
    var snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);
    var bp = BPF.ar(snd, freq, 0.01);
	var chain = FFT(LocalBuf(512), LPF.ar(snd, 2000));
	//Gate main signal from
	var trig = Onsets.kr(chain, 0.2);
	var atk = (EnvGen.ar(Env.perc(0.002, 0.1), trig) * snd);
	/*var combs = (1..8).collect( { |i|
		var x = CombL.ar(atk, 0.2, (freq * i).reciprocal, LFNoise2.ar(2).range(1,10));
		x = RLPFD.ar(x, (freq * i), 0.9, 0.3);
		x
	} ).scramble;
	*///Gate main signal from
	// bp = Compander.ar(Mix(snd).dup, bp, 0.001, 10, 0.01, 0.01, 0.01);
bp = snd;
	bp = CombL.ar(bp, 0.2, freq.reciprocal, LFNoise2.ar(2).range(1, 10)) * 0.5;


	// bp = LinSelectX.ar(Stepper.ar(K2A.ar(trig), 0, 0, 7).lag(1), combs) * 0.5;

	// freq = freq * Demand.ar(Impulse.ar(0) + Dust.ar(0.1), 0, Dxrand((2..8), inf)).lag(0.1);
	bp = RLPFD.ar(bp, freq*4, 0.8, 0.4);
	bp = bp * -1; //SelectX.ar(MouseX.kr, [bp, ~ezConv.ar(bp, 0, mul:0.1)]);

	bp + snd;

	// DC.ar
}).play
)


(
Ndef(\ringzTest, {
    var freq = "d1".namecps;
    var snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);
    var chain = FFT(LocalBuf(512), LPF.ar(snd, 2000));
	//Gate main signal from
	var trig = Onsets.kr(chain, 0.2);

	var atk = (EnvGen.ar(Env.perc(0.2, 0.01), trig) * snd);

	// snd + Ringz.ar(atk, freq, LFNoise2.ar(2).range(1, 5), 0.01);

	snd + Formlet.ar(atk, freq,0.7, 0.74)


}).play
)


(
//Quite good, this one
Ndef(\combTest, {
    var freq = "d1".namecps;
    var comb, snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);

	var partials = [3,7,8,14];

	// snd = (snd * 8).tanh;
	comb = partials.collect { |i, index| CombL.ar((snd * 8).tanh * 0.1, 0.2, (freq * i).reciprocal, LFNoise2.kr(2).range(1, 10))};
	comb = Splay.ar(comb.flatten);
	// bp = LinSelectX.ar(Stepper.ar(K2A.ar(trig), 0, 0, 7).lag(1), combs) * 0.5;

	// freq = freq * Demand.ar(Impulse.ar(0) + Dust.ar(0.1), 0, Dxrand((2..8), inf)).lag(0.1);
	// comb = RLPFD.ar(comb, 7, 0.5, 0.5);
	comb = LPF.ar(comb, freq*9);

	switch(\compander,
		\compander, {
			//Limit output
			comb = Compander.ar(comb, comb, 0.3, 1, 0.1, 0.01, 1);

			//Follow amplitude of original sound
			comb = comb * Amplitude.kr(snd, 1, 6).lagud(15, 15) * 2;
		},
		\ringmod, {
			//or maybe nicer: ring modulate
			comb = HPF.ar(comb, 300) * snd;
		}
	);


	//Dry->Wet



	snd + comb

	// XFade2.ar(snd, comb, MouseX.kr(-1, 1).min(1));

	// DC.ar
}).play
)