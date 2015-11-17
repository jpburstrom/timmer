b = Buffer.alloc(s, 1024);

//Förmodligen är det här bättre med enskilda syntar istället för Ndef...
//

(
//En synt kör FFT i global buffer
Ndef(\fftpt1, {
	var chain,
	snd = Saw.ar(LFNoise2.ar(1).exprange(220, 440)) * 0.05;

	chain = FFT(b, snd);

	DC.ar
}).play(addAction:\addToHead);

//En annan hämtar data och fortsätter jobba
Ndef(\fftpt2, {
	var chain;
	chain = PV_MagSmooth(PV_Copy(b, LocalBuf(1024)), 0.99);
	chain = PV_MaxMagN(chain, 3);
	IFFT(chain)

}).play(addAction:\addToTail);

//En tredje hämtar data och fortsätter jobba
Ndef(\fftpt3, {
	var chain;
	chain = PV_MagSmooth(PV_Copy(b, LocalBuf(1024)), 0);
	chain = PV_MagShift(chain, 2);
	chain = PV_MaxMagN(chain, 3);
	IFFT(chain)

}).play(addAction:\addToTail);
)

NdefMixer(s);

// En synt fixar FFT
// En synt är master
// 4 syntar är freezes
