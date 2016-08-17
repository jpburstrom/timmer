//init
(
"../player/lib/init".import;
~buf = Buffer.read(s, "../player/songs/07*".resolveRelative.pathMatch[0] )
~claps = "../player/samples/handclaps/*.wav".resolveRelative.pathMatch.collect (Buffer.read(s, _ ));
)
//07 tests
//Segmentation & randomization of last part
(
var from = 300;//q.player.data.phrase.last;
var to = 400;//from.sum;
var dur = 60*5;
//Moving from freqshifted to plain
Pdef(\sdf, Pbind(
    \instrument, \bufSegmentFreqshiftMS,
    \freqshift, 0,
    \minSize, 3,
    \maxSize, Pkey(\minSize) * 2.5,
    \dur, Prout({ |ev|

        loop {
            //This splits the part (from..to) into random-sized segments (between 3 and 7)
            var positions = Fdef(\randomSegments).(from, to, ev.minSize, ev.maxSize);
            var durations = (positions ++ to).differentiate[1..];
            var order = Array.series(positions.size).scramble;
            order.do { |index|
                ev.startPos = positions[index];
                ev = durations[index].yield;
            }
        }

    }),
    \bufnum, ~buf,
    \midAmp, Pwhite(-12, 0).dbamp,
    \legato, Pbrown(1.0, 2.0),
    \amp, Plprand(0.02, 0.3),
    //Problem: boring fades
    \pan, Pfuncn({ 0.7.bilinrand }, inf),
    \fadetime, Pwrand([Pfuncn { "click".postln; 0 }, Pwhite(4.0, 5.0, 1)], [0.01, 0.99], inf);
));
)

(
var freqs = \G1.namecps * ((-1..-100) ++ (1..10));
Pdef(\sdf10, Pspawner({ |sp|
    var it = 20;
    var durs = Pseq(it.fib(2,3)).asStream;
    it.do {
        "spawn".postln;
        sp.par(Pbindf(Pdef(\sdf),
            \amp, Pkey(\amp) * 0.7,
            \dur, Pkey(\dur) * Pseg([1, 0.1, 1], 30, repeats:inf),
            \fadetime, Pkey(\fadetime) * Pseg([1, 0.1, 1], 30, repeats:inf),
            //TODO: multiply w/ Pseg long-form
            \freqshift, Pxrand(freqs, inf) * Pseg([1, 0, 1], 30, repeats:inf)
        ));
        durs.next.wait
    }
})).play
)


(
Pdef(\claps, Pbind(
    \instrument, \bufSegmentFreqshiftMS,
    \freqshift, Pwhite(-500, -10000),
    \midAmp, Pwhite(0.1, 2),
    \sideAmp, Pwhite(0.1, 2),
    \bufnum, Pseq(~claps, inf),
    \dur, Pwhite(0.01, 0.06) * Pseg(Pwhite(1.0, 10.0), Pwhite(1.0, 20.0)),
    \sustain, 0.5,
    \amp, Pseg([1, 0.01, 0], Pseq([10, Pwhite(10, 30, 1)], inf), Pseq([\exp, \lin], inf), inf)
)).play;
)

Pdef(\claps).stop

(
//Synthesizer
Pdef(\gloglo, Pbind(
    //TODO: change instrument
    \instrument, \fmGloss,
    \dur, Pbrown(0.01, 0.2, 0.009),
    \sustain, Pseq([0.01, 0.02, 0.03], inf),
    \freq, Pseg(Pwhite(40, 80), 10),
    \amp, Pbrown(0.1, 0.3, 0.01),
    \out, 0,
    // \timingOffset, Pwhite(0.0, 0.05),
    // \strum, Pwhite(0.0, 0.1),
    // \degree, 0
)).play
)
Pdef(\gloglo).stop