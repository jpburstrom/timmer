//init
(
"../player/lib/init".import;
~buf = Buffer.read(s, "../player/songs/07*".resolveRelative.pathMatch.reverse[0] );
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
    \amp, Plprand(0.02, 0.5),
    //Problem: boring fades
    \pan, Pfuncn({ 0.7.bilinrand }, inf),
    \fadetime, Pwrand([Pfuncn { "click".postln; 0.002 }, Pwhite(4.0, 5.0, 1)], [0.01, 0.99], inf);
));
)


(
////////
//SONG//
////////
var freqs = \G1.namecps * ((-1..-100) ++ (1..10));
Pdef(\sdf10, Pspawner({ |sp|
    var st = ();
    var it = 8;
    var type = \note;

    var durs = Pgeom(15, 0.9, it).integrate.asStream - 15;
    it.do {
        sp.par(Pbindf(Pdef(\sdf),
            //Route two signals,
            \amp, Ptuple([Pkey(\amp), 0.5 - Pkey(\amp)]) * 0.7,
            \out, [0, 2],
            \type, Pfunc { type },
            \dur, Pkey(\dur) * Pseg([1, 0.7, 1], 30, repeats:inf),
            // \fadetime, Pkey(\fadetime) * Pseg([1, 0.1, 1], 30, repeats:inf),
            //TODO: multiply w/ Pseg long-form
            \freqshift, Pxrand(freqs, inf) * Pseg([1, 0, 1], 30, repeats:inf) * Pseg([0, 1, 1, 0], Pseq([30, 150, 60])),
        ), durs.next);
    };
    // sp.wait(45);
    // Ndef(\fbfb).end;
    sp.wait(200);
    Ndef(\meckamack_07).play;
    sp.wait(100);
    "Ndef comes here".postln;
    Ndef(\fbfb).play;
    type = \rest;
    sp.wait(10.rrand(20));
    type = \note;

    sp.suspendAll;
    st.claps = sp.par(Pdef(\claps), 0.0.rrand(3));
    st.glo = sp.par(Pdef(\gloglo), 0.0.rrand(3));
    st.test07 = sp.par(Pdef(\test07), 0.0.rrand(3));

    5.rrand(20).wait;
    // sp.suspendAll; //TODO fade/wait for next, especially \test_07 is a bit harsh...


    Ndef(\fbfb).play ; //bug: doesn't play

    //Finish off a bit randomly
    st.values.scramble.do { |stream|
        2.0.rand.wait;
        sp.suspend(stream);
    };
    //Fade out last
    Ndef(\meckamack_07).fadeTime = 20;
    Ndef(\meckamack_07).end;

    //wait for \fbfb to stop

})).play
)
Pdef(\test07).stop
NdefMixer(s)
Pgeom(15, 0.7, 4).integrate.asStream.nextN(4)
1.next
(
Pdef(\claps, Pbind(
    \instrument, \bufSegmentFreqshiftMS,
    \freqshift, Pwhite(-500, -10000),
    \midAmp, Pwhite(0.1, 1),
    \sideAmp, Pwhite(0.1, 1),
    \bufnum, Pseq(~claps, inf),
    \dur, Pwhite(0.01, 0.06) * Pseg(Pwhite(1.0, 10.0), Pwhite(1.0, 20.0)),
    \sustain, 0.5,
    \amp, Pseg([1, 0.01, 0], Pseq([10, Pwhite(10, 30, 1)], inf), Pseq([\exp, \lin], inf), inf) * 0.4
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
    \amp, Pbrown(0.1, 0.3, 0.01) * Pseg([1, 0.0001], 100, \exp) * 0.1,
    \out, 0,
    // \timingOffset, Pwhite(0.0, 0.05),
    // \strum, Pwhite(0.0, 0.1),
    // \degree, 0
))
)
Pdef(\gloglo).stop
Pdef(\gloglo).play