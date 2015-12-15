

(
Tdef(\freezer, {
	loop {
		Ndef(\freezer, {
			var snd, chain = PV_Copy(~fftbuf, LocalBuf(2048));
			//chain = PV_MagSmooth(chain, Line.kr);
			snd = IFFT(chain);
			snd = PitchShift.ar(snd, 0.2, 2.midiratio);
			snd = snd * 12;
			snd = Compander.ar(snd, snd, 0.1, 1, 0.33);
			//DelayC.ar(snd, 1, 1);
		}).play(0);
		10.wait;
	}
}).play
)

Tdef(\freezer).stop

(
//This works
Ndef(\freezer, {
	var snd, chain;
	var fftsize = 8192;
	var wait=fftsize*SampleDur.ir;
	wait.poll;
	snd = In.ar(~freezeBus);
	chain = FFT(LocalBuf(fftsize), snd);
	chain = PV_MagSmooth(chain, Latch.kr(1, TDelay.kr(Impulse.kr(0), wait)));
	snd = IFFT(chain);
	snd = snd * EnvGen.ar(Env([0, 0, 1], [wait, 3], -2)); //fade up before time-based processing
	snd = PitchShift.ar(snd, 0.6, 17.midiratio);
	snd = snd * 1;
	snd = Compander.ar(snd, snd, 0.1, 1, 0.33);


}).play(2, fadeTime:0);
)

Ndef(\freezer).end

x.free