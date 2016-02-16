(
~buf = Buffer.read(s, "../../render/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;
)


(
SynthDef(\varTest, { |bufnum, startPos, attackStartPos, sustain(0), bufRate(1), varFactor(0)|
    var snd, attack, release,
	fadetime = 0.002; //short fade to avoid clicks
	var attackDur = 0.06; //Duration of attack part

	//Different positions for attack and sustain parts
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples
	attackStartPos = ((attackStartPos - fadetime) * BufSampleRate.kr(bufnum)).max(0); //Convert seconds to samples

	//Randomize attack pitch
	attack = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * bufRate * LFNoise2.kr(Rand(1,5)).range((-10 * varFactor).midiratio, (1 * varFactor).midiratio), startPos: attackStartPos);

	//release part is left blank
    snd = release = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * bufRate, startPos: startPos);

	//Different filtering possibilities
	//attack = LPF.ar(attack, ExpRand(10000, 20000));
	//attack = attack + LPF.ar(DelayC.ar(attack, 0.1, Rand(0, 0.1), -1), 1000);
	// release = release * ExpRand(0.707, 1);

    //mix attack and release
	snd = LinSelectX.ar(1, [snd, LinSelectX.ar(Line.ar(0, 1, attackDur), [attack, release])]);
    Out.ar(32, \klank.kr * EnvGen.ar(Env.perc(0.002, 0.03)) * attack);
	//output + envelope
	snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    Out.ar(\outbus.kr(0), snd);
}).add;
)

(

Ndef(\klank, {
    var freqs = [1, 1.0019054878049, 1.7936737804878, 1.8009908536585, 2.5201981707317, 2.5224085365854, 2.9907012195122, 2.9940548780488, 3.7855182926829, 3.8061737804878, 4.5689024390244, 4.5754573170732, 5.0296493902439, 5.0455030487805, 6.0759908536585, 5.9094512195122, 6.4124237804878, 6.4430640243902, 7.0826219512195, 7.0923780487805, 7.3188262195122, 7.5551829268293] * 2;
    var amps = freqs.size.collect((_+1).reciprocal);
    var times = freqs.size.collect { Rand(1, 9.5) };
    DynKlank.ar(`[freqs, amps, times], In.ar(32, 2) * 0.01, \freq.kr(150) * LFNoise2.kr(4).range(0.99, 1.01));
}).play;
)
Ndef(\klank).gui
(
Pdef(\varTestTest, Pbind(
	\instrument, \varTest,
    \legato, 1,
	\counter, Pseries(0, 1, ~onsets.size - 1), //count through all segments and stop
	\varFactor, Pseg([0, 0, 1, 1], 120) ++ Pn(1), //general variation amount
	\isRandom, Pfunc { |ev| ev.varFactor.coin }, //flip a coin depending on varFactor

	//If isRandom, select one of a few chosen segments. Otherwise use value of segment counter
	\segment, (Pif(Pkey(\isRandom), Pxrand([5, 40, 41, 233, 234], inf), Pkey(\counter)) ++ (~onsets.size - 1)),
	\attackSegment, Pkey(\counter), //But the attack is always using the segment counter

	\bufRate, Pwhite(-0.03.midiratio, 0.03.midiratio), //maybe unnecessary pitch deviation
    \ctranspose, 7,
    \octave, 4,
    \scale, Scale.majorPentatonic,
    \degree, Pwhite(0,5),
    \klank, p { loop { 16.rrand(24).do { 0.yield }; 1.yield } },
    \dummy, Pfunc({ |ev|
		//Lookup onset and duration times
        ev.startPos = ~onsets[ev.segment];
		ev.dur = (~durations[ev.segment] * ev.bufRate) * 0.95.rrand(1); //duration is a bit randomized
		ev.attackStartPos = ~onsets[ev.attackSegment];
		//GC(\varFactor).value = ev.varFactor;
    });
)).play;

)
Pdef(\varTestTest).stop