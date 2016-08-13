~ez = EZConv("../player/data/impulses/impulse-closed-ms-48.wav".resolveRelative);
~ez = EZConv("/private/tmp/r1_ortf-48k.wav")
(
//
SynthDef(\msConv, { |inbus=0, outbus=0|
	// var snd = SinOsc.ar(LFNoise0.ar(5).exprange(200,300), 0, 0.1);
	var fftsize = 4096;
	var mid, side;
	var irbufs = \irbufs.kr(~ez.irSpectrum);
	var snd = In.ar(inbus, 2).sum; //Just mix the source to mono

	//First buffer holds mid impulse, second side
	mid = PartConv.ar(snd, fftsize, irbufs[0], 0.0631); //set amp to -24db
	side = PartConv.ar(snd, fftsize, irbufs[1], 0.0631); //set amp to -24db

	//Mix mid and side individually. Seems good to have side at at least -6db, but depends on impulse
	mid = mid * \midAmp.kr(1);
	side = side * \sideAmp.kr(0.501);

	//Convert to stereo
	snd = [mid - side, mid + side] * \amp.kr(0.25);

	Out.ar(outbus, snd)
}).add
)