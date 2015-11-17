(
Ndef(\microshift, {
	var snd;
	var range = 0.03;
	var speed = 2;
	snd = SinOsc.ar * 0.1;
	snd = DelayC.ar(snd, 0.2, LFTri.ar(speed).range(0, range));
	snd = [snd, SinOsc.ar(440 + ((speed * 0.5)/range)) * 0.1]
}).play;
)
{  LFTri.ar(2).range(0, 0.03) }.plot(1)

2/0.03