ScoreClock.beginScore;
(
b = Buffer.cueSoundFile(s, "/Volumes/HD2/projects/timmer/render/NR/mollackorden-96khz 20120907-113153.wav");
SynthDef(\timmerNoiseRemoval, {
		var son = DiskIn.ar(2, b);
		var fft = LocalBuf(16384);
		var chaincopy, chain = FFT({LocalBuf(16384)} ! 2, son, 0.25);
		chaincopy = PV_Copy(chain, { LocalBuf(16384)} ! 2);
		chain = PV_MagSmooth(chain, 0.93);
		chain = PV_MagSubtract(chaincopy, chain, 1);
		chain = PV_MinMagN(chain, 8189);
		Out.ar(0, 1 * IFFT(chain, 1));
}).add;
)
Pbind(
		\instrument, \timmerNoiseRemoval,
		\delta, Pseq([4*60+50])
).play(ScoreClock);


z = ScoreClock.makeScore((4*60)+51);
z.render("/Volumes/HD2/projects/timmer/samples/mollackorden-subtract-96khz.aif", (4*60)+51)

z.recordNRT("/tmp/score.osc", "/tmp/score.aiff", sampleRate:96000, sampleFormat:"int24", options: ServerOptions.new.numOutputBusChannels_(2))
