~buf = Buffer.read(s, "songs/10*".resolveRelative.pathMatch[0]);


~midside ={ arg input, scale = -3;   [input[0] + input[1], input[0] - input[1]] * scale.dbamp };
(
Ndef(\FreqshiftThing_10, {
	var freq = [72.5, 157];
	var bp, snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);

	//M-S encoding
	snd = ~midside.value(snd);

	//rq decides on
	bp = BPF.ar(snd[1], freq, 0.006) * 12;//LFNoise2.kr(4).range(18, 24).dbamp;


	bp = FreqShift.ar(bp, [freq[0] * -0.5, (freq[1] * 1.5) - freq[1]]);

	bp = bp.sum;

	snd[1] = (snd[1] * LFNoise2.kr(0.1).exprange(1,2));

	snd[1] = snd[1] + bp;

	snd[1] = snd[1] + LPF.ar(CombL.ar(snd[1].neg, 0.2, 205.reciprocal, 1));

	//This is good -- frequency shift side part
	//match frequency with audio (in this case (01) a lot of D)
	snd[1] = FreqShiftAA.ar(snd[1], -670, mul:3);





	//Remove mid
	// snd[0] = DC.ar;

	~midside.value(snd).reverse;

	// DC.ar
}).play
)

