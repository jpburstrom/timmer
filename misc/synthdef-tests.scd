(
"../player/lib/01-synthdefs".import;
~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;
)

(
//This one is quite nice, but
Pdef(\combDDrone, Pbind(
	\instrument, Pwrand([\bufSegmentComb, \bufSegment], [0.6, 0.4], inf),
	\startPos, Pseq(~onsets),
	\dur, Pseq(~durations),
	\combAttack, 0,
	\combDecay, 12,
	\combDecayDev, 0.2, //LFNoise subtracted from combDecay
	\combDecayDevSpd, 0.1,
	\legato, 1,
	\bufnum, ~buf,
	//Play a d note
	\note, 2,
	//Choose a good harmonic. if too close to
	\harmonic, Pwhite(2, 4),
	\octave, 3,
	\ffreq, Pkey(\freq) * 5,
	\fres, Pwhite(0.7, 0.85), //High resonance is needed to make it sound good
	\fdist, 0.8,
	//The hard part is to get a good mix. Depending on input, the amplitude can vary
	//quite much, and it needs to stay in the background to work
	\mix, -0.95

)).play;
)