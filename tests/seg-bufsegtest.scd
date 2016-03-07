b = Buffer.read(s, "/Volumes/HD2/projects/timmer-2015/render/01-Preparerad flageolett 2 ___-44100.wav");

(
SynthDef(\bufSegment, { |out(0), bufnum(0), startPos(0), sustain(1)|
    var fadetime = 0.02;
    var snd;
    startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(out, snd);
}).add;
)

Synth(\bufSegment, [\buf, b, \dur, 2])

(
~times = FileReader.read("/Volumes/HD2/projects/timmer-2015/creations/single/S15-3 Preparerad flageolett/data/onsets.txt").flop[0].collect(_.asFloat);
~durations = ~times.differentiate[1..];
//Add last segment duration
~durations = ~durations.add(10);

)

(
//Randomize order of segments
//Works quite well on low amplitudes
//Needs to detect soft parts and make the switch then
//Can't switch directly after loud note
Pdef(\bufSegTest, Pbind(
    \instrument, \bufSegment,
    \buf, b,
    \bufRate, 1,//Pstutter(2, Pwrand([-1,0], [0.1, 0.9], inf).midiratio),
    \stretch, 1,// Pbrown(0.1, 1, 0.05),
    //\index, Pseries(0, 1, ~times.size).trace,
    //Random start index
    \index, Pwhite(0, ~times.size).trace,
    \startPos, Pfunc { |ev| ~times[ev.index] },
    //Random length (2-6 segments)
    \dur, Pfunc { |ev| var count = 1.rrand(5); ~durations[ev.index..ev.index+count].sum },
    \legato, 1,

)).play;
)


(
//Stretch timing with brown noise
//
Pdef(\bufSegTest, Pbind(
    \instrument, \bufSegment,
    \buf, b,
    \bufRate, 1,//Pstutter(2, Pwrand([-1,0], [0.1, 0.9], inf).midiratio),
    //Stretch
    \stretch, Pbrown(0.8, 1, 0.05),
    \index, Pseries(0, 1, ~times.size).trace,
    \startPos, Pfunc { |ev| ~times[ev.index] },
    \dur, Pfunc { |ev| ~durations[ev.index] },
    \legato, 1,

)).play;
)

//Other ideas:
//Switch only to segments with similar previous note
//Compare similarity between segments, jump to segment with more or less similarity
//somehow work with timing of original -- make more/less extreme
//repeat x segments (123 2345 2345 45678 5678...)

