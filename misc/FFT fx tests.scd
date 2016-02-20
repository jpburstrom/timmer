(
~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;
)

(
SynthDef(\timmerTest, { |index, startPos, sustain, bufnum|
	var fadetime = 0.02;
	var snd, chains, snd2;
	var i = index;
	var windowsize = 2048;
	var latency = 44.1/windowsize*2;
	var randFreq;
	startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);

	snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);

	// snd2 = DelayC.ar(snd, latency, latency);

	chains = FFT({LocalBuf(windowsize)}.dup, snd );

	//-----FFT Experiments-----//

	//Remove tonal information
	//chains = PV_MagSmear(chains, 5);

	//Freeze a note after the attack phase
	//Could put an envelope before FFT and make the note sustain longer than possible
	//chains = PV_MagFreeze(chains, Stepper.kr(TDelay.kr(Impulse.kr(0), 0.28)));

	//Some sort of spectral shift envelope
	//Envelope is multiplying bins with 1.1, with a probability of 0.1
	//chains = PV_MagShift(chains, EnvGen.kr(Env([1, 1, 1 + ((Rand() > 0.9) * 0.1)], [0.08, sustain], \lin)));

	//Down is also nice
	//But better on loud & low notes?
	// chains = PV_MagShift(chains, EnvGen.kr(Env([1, 1, 1 - ((Rand() > 0.9) * 0.5)], [0.08, sustain], \lin)));

	//Also quite interesting! Would be good to experiment more with.
	// chains = PV_RectComb(chains, 64, Rand(0.1, 0.3), width: 0.4);

	//A kind of pitchshift
	//chains = PV_PhaseShift(chains, Line.kr(Rand(0, 180), Rand(0, 180), 1));

	// snd2 = IFFT(chains);



	//-----Other fun stuff-----

	//FreqShift of release part, do we have latency here?
	randFreq = ExpRand(10, 100); 4.do { snd2 = HPF.ar(snd2, randFreq) }; snd2 = FreqShift.ar(snd, randFreq * -1);

	//What happens if attack is freqShifted as well?
	//snd = snd2;


	//----IFFT, but keep attack------
	snd = LinSelectX.ar(EnvGen.ar(Env([0, 0, 1], [0.08, fadetime])), [DelayC.ar(snd, 0.2, latency), snd2]);





	snd = snd * EnvGen.ar(Env([0, 0, 1, 1, 0], [latency, fadetime, sustain, fadetime]), doneAction:2);

	Out.ar(0, snd);
}).add;
)

(
Pdef(\tTest, Pbind(
	\instrument, \timmerTest,
	\legato, 1,
	\startPos, Pseq(~onsets),
	\dur, Pseq(~durations),
	\bufnum, ~buf,

)).play;
)

20