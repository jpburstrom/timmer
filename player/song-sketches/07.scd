~buf = Buffer.read(s,"/Users/johannes/projects/timmer/kod/player/songs/07-Drone maskin 1 ___-44100.wav" );

s.boot
~midside ={ arg input, scale = -3;   [input[0] + input[1], input[0] - input[1]] * scale.dbamp };
(
x = Ndef(\FreqshiftThing_10, {
	var bp, snd = PlayBuf.ar(2, ~buf, BufRateScale.kr(~buf) * \bufRate.kr(1), Changed.kr(\startPos.kr), \startPos.kr);

	//M-S encoding
	snd = ~midside.value(snd);

	// snd[1] = FreqShiftAA.ar(snd[1], -10);
	// snd[1] = snd[1] * 2;

	snd[1] = snd[1] * SinOsc.ar(LFNoise2.kr(0.2).range(96,106)) * 5;

	~midside.value(snd).reverse;

	// DC.ar
}).play
)

x.record
x.resume
x.stop
x.close

Ndef(\FreqshiftThing_10).stop

{ SinOsc.ar(MouseX.kr(80, 200).poll) * 0.1 }.play

s.record
Server

~buf