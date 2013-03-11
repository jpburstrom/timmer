(
var windowSize = 8192;
var path = "/Volumes/Mega/projects/timmer/render/to SC/single-note-arco.wav";
var sf = SoundFile.new(path);
sf.openRead;

sf.openRead;
sf.close;
y = Buffer.alloc(s, sf.duration.calcPVRecSize(windowSize, 0.25));
b = Buffer.read(s, path);

SynthDef("pvrec", { arg recBuf=1, soundBufnum=2;
	var in, chain, bufnum;
	bufnum = LocalBuf.new(windowSize);
	Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
	in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
	// note the window type and overlaps... this is important for resynth parameters
	chain = FFT(bufnum, in, 0.25, 1);
	chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, 0.25, 1);
	// no ouput ... simply save the analysis to recBuf
}).add;
)

Synth("pvrec", [\recBuf, y, \soundBufnum, b]);

(
var windowSize = 8192;
SynthDef("timmer.freezeNote", {
	arg out=0, recBuf=1, soundBufnum=0, amp=1, pan=0, note, freq=440, startPos=0, attack=0.1, release=0.1, sustain=1, soundXFadeDelay=0, soundXFade=0;

	var
	  sound,
		chain = LocalBuf.new(windowSize),
		pos = WhiteNoise.ar(0.0, 0.6); //Line.kr(startPos.max(0.1), 1, sustain+release);

	sustain = (sustain - attack).max(0.01); //subtract AD, for Env
	freq = freq/440; //Convert to ratio

	chain = PV_BufRd(chain, recBuf, pos);
	chain = PV_BinShift(chain, freq, 1);
	//chain = PV_RandComb(chain, EnvGen.kr(Env([0,1], [sustain+release], curve: -3)));
	//chain = PV_MaxMagN(chain, EnvGen.kr(Env([4096, 10], [sustain+release], curve: -5)));
	//chain = PV_MaxMagN(chain, 1);
	sound = XFade2.ar(
		PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum) * freq, startPos: BufFrames.kr(soundBufnum) * startPos),
		IFFT(chain, 1),
		EnvGen.kr(Env([-1, -1, 1], [soundXFadeDelay, soundXFade]))
		) * EnvGen.ar(Env.linen(attack, sustain, release, curve:\cubed), doneAction:2);
	Out.ar(out, Pan2.ar(Decimator.ar(sound,12000, 12), pan, amp));
}).add;
)
Synth("timmer.freezeNote", [\recBuf, y, \soundBufnum, b]);

Env([1,4096], [1], curve: 5).plot

Pdef(\test3, Pbind( \instrument, 'timmer.freezeNote', \soundBufnum, b, \recBuf, y, \amp, 1, \dur, Pbrown(2.3,2.8, 0.1) * 0.25, \legato, 1, \release, 2, \attack, Pbrown(0.001, 0.04), \note, Pstutter(Pwhite(1,2), Pseq([8, 10], inf)),  \scale, #[0,5,7,10], \startPos, Pwhite(0.0, 0.05))).play
