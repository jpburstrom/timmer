~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~midside ={ arg input, scale = -3;   [input[0] + input[1], input[0] - input[1]] * scale.dbamp };
(
Ndef(\combTest, {
	var freq = [72.5, 157];
	var bp, snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), 1, 0);

	//M-S encoding
	snd = ~midside.value(snd);

	//rq decides on
	bp = BPF.ar(snd[1], freq, 0.006) * 12;//LFNoise2.kr(4).range(18, 24).dbamp;


	bp = FreqShift.ar(bp, [freq[0] * -0.5, (freq[1] * 1.5) - freq[1]]);



	// bp = bp + AllpassC.ar(bp);

	// bp = Mix(bp);

	bp = bp.sum;

	//idea: randomly change volume of side channel (change 3
	snd[1] = (snd[1] * LFNoise2.kr(0.1).exprange(1,2));

	snd[1] = snd[1] + bp;

	//This is good -- frequency shift side part
	//match frequency with audio (in this case (01) a lot of D)
	{
		var index = 1;
		4.do { snd[index] = HPF.ar(snd[index], 290) };
		snd[index] = FreqShift.ar(snd[index], -290) * 3;
	}.value;




	//Remove mid
	// snd[0] = DC.ar;

	~midside.value(snd).reverse;

	// DC.ar
}).play
)

