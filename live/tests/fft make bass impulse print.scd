~bassImpulse = Buffer.read(s, "/Users/johannes/projects/timmer/2015/creations/reverb sweep/doublebass.wav");
~bassImpulse.normalize;
~bassPrint = Buffer.alloc(s, 4096);
(
{
	var chain, snd = PlayBuf.ar(1, ~bassImpulse, doneAction:2);
	chain = FFT(~bassPrint, snd);
	//chain = PV_Invert(chain);
	/*snd = IFFT(chain);
	snd = BHiShelf.ar(snd, 300, 1, -32) * 12.dbamp;
	chain = FFT(~bassPrint, snd);
	*/DC.ar
}.play
)


(
{
	var snd = WhiteNoise.ar * 0.1;
	var chain = FFT(LocalBuf(4096), snd);
	chain = PV_MagMul(chain, ~bassPrint);
	IFFT(chain);


}.play
)

PV_Invert

PV_SpectralEnhance