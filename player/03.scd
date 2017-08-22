//## Initialize ###
(
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;
var impulsePath = "data/impulses/impulse-closed-ms-48.wav".resolveRelative;
var plankPath = "lib/protos/buffer-pool.scd".resolveRelative;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("03");
q.player.data.tail = 0;
//q.player.extractFeatures;
// q.playerui.connect(q.player);


//## Patterns #######

q.player.onReady = {

    var compLookahead = 0.01;
    var revSize = 2;

    ~data.lastNote = false;

    ~t.plankBuf = plankPath.load;
    ~t.plankBuf.initBuffers(8, 2);
    s.sync;
    //POST FX
    ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.8, \ratio, 3, \attack, compLookahead, \release, 0.1, \amp, 1],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    ~t.mixin = Monitor().play(~t.mainOut.index, 2, ~t.fxOut.index, 2, ~t.postGroup, false, 0.1);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \amp, 0.1, \damp, 0.9, \size, revSize],
        ~t.sendGroup, \addToTail);

    //FIX FX LATENCY
    ~t.latencyFix = Synth(\fixedDelay,
        [\outbus, ~t.mainOut, \maxDelay, compLookahead, \delay, compLookahead],
        ~t.sendGroup, \addToTail);

};

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Plazy {
    var totaldur = 2;
    Pbind(
        \instrument, \diskSegment,
        \timingOffset, 0.1, //Delay compensation for Ptpar
        \legato, 1,//Pstep([1], Pseq([totaldur]), 1) ++ Pfuncn { |ev| (ev.dur - 0.1) / ev.dur }, // cut tail of last note
        // \fadetime, Pstep([0.01], Pseq([totaldur]), 1) ++ Pn(0.5, 1),
        \type, Pseq([\rest, Pn(\note, inf)]),
        // \dur, Pkey(\dur) * Pwrand([0.1, 1], [0.1, 0.9], inf)
        // \dur, Pkey(\dur) * Pseg(Pwhite(0.8, 1), 4)
)});

q.player.parPtn = Ptpar([0.1, Pbind(
    //TODO: 3rd channel is discarded. Use 2-channel version of file?
	\instrument, \diskSegmentPlank,

    //Sometimes clump
    \clump, Pwrand([1,2], [0.9,0.1], inf),
    //Randomize start position from onsets
    \index, Pclump(Pkey(\clump), Pwhite(0, Pfunc { ~currentEvent.onset })), //Randomize among already played onsets
    \startPos, Plazy({ var times = ~data.onset.flop[0]; Pfunc { |ev| times[ev.index] } }) + Pwhite(-0.01, 0.02),
    \bufnum, Pfunc { |ev| ~t.plankBuf.next(~soundFile, ev.startPos) },
    //Choose 5 new overtones of E1 and F1, A1 every 25-50
    //Randomly clumped
    \freq, Pclump(Pkey(\clump),
        Pn(Plazy { |ev| Prand(([40, 41, 45].midicps *.x (2..8)).select(_ > 200).scramble.keep(5), ev) })),
    \pan, Pkey(\freq).explin(60, 800, -0.2, 0.2),
    \sustain, Pkey(\freq).wrap(1, 3) * Pwhite(0.5, 1),

    //Get total duration for some later Pseg patterns
    \totalDur, p { var dur = ~data.onset.last[0]; loop { dur.yield } },
    //Divide ~currentEvent (bass note) duration into equal-length segments according to \divisions pattern
    \divisions, Pif(Pfunc { ~data.lastNote }, 1, Pwhite(1,
        Pseg([5,1.5,5,1.5,3],
            Plazy { Pseq([[0.5, 1], [4.0, 6], [2.0, 5], [1.0, 9.0]].collect(_[0].rrand(_[1])).normalizeSum) } * Pkey(\totalDur),
            \lin, inf))),
    \dur, PdurStutter(Pkey(\divisions).round, Pfunc { |ev| ~currentEvent.dur }),
    \group, Pfunc { ~t.mainGroup },

    //Humanize
    \timingOffset, Plprand(0.00, 0.05),
    //Strum if clump
    \strum, Pwhite(0.05, 0.1),
    //Add phrase pauses
    \amp, p { |ev|
        var amp, rest;
        loop {
            30.rrand(100).do {
                ev = 1.yield;
            };
            0.rrand(30).do {
                ev = \rest.yield
            }
        }
    },
    //Output -> second stereo pair
    \outbus, Pfunc { ~t.fxOut }
)]);
//Give a pattern to setIterator, which is used to select which tick is to be played
q.player.setIterator(Plazy {
    var last = 345; //last wanted onset
    //Start at random point, play `(last - 1)` segments, wrapped between `0` and `(last-1)` and finish with `last`
    Pfin(last - 1,
        (Pseries(last.rand) + Pstutter(Pwhite(1,3), Pwrand([0, Pwhite(-10, -3, 1)], [0.95, 0.5], inf))).wrap(0, last-1)
    ) ++ Pfuncn({ ~data.lastNote = true; last }, 1)
//q.player.play
});
)

/*EOF*/

q.player.play(340)
q.player.randSeed = 1234
(
q.player.randSeed = 12345;
q.player.play
)
