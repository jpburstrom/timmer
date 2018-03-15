//# Template for songs ###

//## Initialize ###
(
var relPath = "".resolveRelative;
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("08");
q.player.data.tail = 1;
//q.player.extractFeatures;
// q.playerui.connect(q.player);
q.player.monitorGain = -1.dbamp;
// q.markov = "/lib/protos/markov-trainer".import;

//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar

//Channel map: Bass, Resonator, Handclap, Rev, Piezo





q.player.onReady = {
    var compLookahead = 0.01;
    var revSize = 0.3;

    ~t.handclaps = handClapPaths.pathMatch.collect { |path|
        Buffer.read(s, path);
    };

    /*

    ~t.irSpectrum = 2.collect {|i|
    Buffer.read(s, relPath +/+ "data/impulses/impulse-closed-ms-48_NRT_%.wav".format(i));
    };
    ~t.convBus = Bus.audio(s, 2);
    s.sync;

    ~t.conv = Synth(\msConv, [\inbus, ~t.convBus, \outbus, q.stereo.if(0, 2), \irbufs, ~t.irSpectrum,
    \sideAmp, 1, \amp, 0.25
    ], ~t.sendGroup);

    //TODO: separate send bus for reverb
    ~t.reverb = Synth(\plate_reverb_2x2, [\amp, -3.dbamp,
    \bandwidth, 5000, \decay, 0.01, \predelay, 10, \outbus, q.stereo.if(0,6), \excursion, 0.9,
    \in_diff1, 0.36, \in_diff2, 0.40
    ], ~t.sendGroup);
    */

    //POST FX

    ~t.softclip = Synth(\softclip,
        [\outbus, ~t.fxOut, \pregain, 4, \amp, 0.2],
        ~t.postGroup, \addToTail);
    //zap bad values before sending to verb
    ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

    //SEND FX
    ~t.verb = Synth(\jpverb,
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \time, 0.2, \modDepth, 0.2,
            \modFreq, 0.2,
            \amp, 0.15, \damp, 0.8, \size, revSize],
        ~t.sendGroup, \addToTail);

    //XXX tmp
    //~t.monitor.fx.vol = 0;
};

q.player.use {

    var tmp;


    ~data.endSegment = 350.rrand(370);

    ~data.grouping = #[
        //Part one, onset groups
        [ 0, 1, 2, 3, 1, 4, 5, 1,
            6, 7, 1, 7, 8, 9, 7, 10,
            7, 11, 12, 13, 7, 12, 14, 9,
            15, 7, 12, 14, 16, 17 ]
    ];

    //Shorten last onset
    ~data.onset[~data.onset.lastIndex][1] = 2;

    ~data.iterators = [
        //Scramble order of first part, but don't put two in the same group after each other
        //0
        Plazy { Pn(0,1) ++ Pseq(
            Fdef(\scrambleAvoidSimilar).(~data.grouping[0].dup(3).flatten)  % ~data.grouping[0].size) },
        //1
        Pseries(30, Prand([1, 2], inf), 34).wrap(30, 64),
        //2
        Plazy {
            Pseq((64..76).scramble)
            ++ Pseq((77..80))
            //This is a bit
            ++ Pwalk((81..90), Pwrand([-2, 1, 2], [0.3, 0.4, 0.4], 30.rrand(40)))
        },
        //3
        Pseq((91..105)),
        //4
        Pseq((106..218)),
        //5
        //Pseq((219..272)),
        Ppatlace([
        Plazy { Pseq(
                Fdef(\scrambleAvoidSimilar).(~data.grouping[0])  % ~data.grouping[0].size) },
        Pseries(301, 1, ~data.endSegment - 301),
        ], inf),
        // Pshuf(Array.series(~data.endSegment - 301, 301)),
        //6
        Pseq((419..427), 1),


        // ~p7 = Pn(0);
    ];

    //Pattern with shuffled parts
    //sets ~data.currentPart
    ~setIterator.value(Prout { |ev|

        var stream;

        //Array.series(~data.iterators.size).scramble
        // (4..6)
        // [6,0,2,1,3,5,4,7]
        // (0..6)//[0,1,2,3,0,4,6,7]
        (0..6)
        .do { |index|
            ~data.currentPart = index;
            ev = ~data.iterators[index].embedInStream;
        };

        // Pseq((1..2)).embedInStream;
    });

    // ~setIterator.value(Pseq([425, 426, ~data.onset.size - 1]));
};

//## Patterns #######

//This sets a pattern used to modify the base player pattern.
q.player.setPtn(Plazy({

    Pbind(
        //\startPos, Pkey(\startPos) - 0.002,
        //timingOffset to calculate ~nextEvent before \parPtn
        \timingOffset, 0.05,
        \firstOnsetAdjustment, Pseq([0.1, Pn(0)]),
        \dur, Pkey(\dur) + Pkey(\firstOnsetAdjustment),
        \startPos, Pkey(\startPos) - Pkey(\firstOnsetAdjustment),
        // \startPos, Pkey(\startPos) - 0.1,
        \parPtn, Prout({ |ev|

            var blacklist = (118..122) ++ (134..139) ++ (175..186) ++ (192..199),
            claps = Pbind(
                \instrument, \bufHandclaps,
                \outbus, Pfunc { ~t.fxOut },
                \bufnum, Ppatlace([Rest(), Rest(), Pn(Plazy({ Pshuf(~t.handclaps) })) ], inf),
                \amp, 2,
                \delta, Pfunc { ~currentEvent.dur },
                // \timingOffset, Pwhite(-0.02, 0.02),
                \group, Pfunc { ~t.mainGroup }
            ),
            claps2 = Pset(\amp,
                Pif(Pfunc { blacklist.includes(ev.onset).not and: { 0.7.coin } },
                    2, Rest(0)),
                claps
            ),
            return = {
                ev = 0.yield;
            },
            curPart,

            //To be called from within q.player environment
            spawnResonator = {
                ~t.resonator ?? {
                    ~t.resonator = Synth(\resonate_08, [\inbus, ~t.mainOut, \outbus, ~t.fxOut], ~t.postGroup);
                };
            },

            releaseResonator = {
                ~t.resonator !? { ~t.resonator.release };
                ~t.resonator = nil;
            },
            parStream,
            spawnParPtn = { |ptn|
                //Stop previous stream
                ~spawner.suspend(parStream);
                //Adjust to timing offset of parent pattern
                parStream = ~spawner.par(ptn, ev.timingOffset);
            }
            ;

            loop {
                if (~data.currentPart != curPart) {

                    if (~data.currentPart < 2) {
                        //First 4 parts are similar, only start resonator and stream
                        //if we're arriving from somewhere else
                        if (curPart.isNil or: { curPart > 1 }) {
                            spawnResonator.();
                            //spawnParPtn.(claps);
                        }
                    } {
                        ~data.currentPart.switch(
                            2, {
                                spawnResonator.();
                                ~spawner.suspend(parStream);
                            },
                            /*
                            3, {
                                spawnResonator.();
                                ~spawner.suspend(parStream);
                            },
                            */
                            4, {
                                releaseResonator.();
                                //spawnParPtn.(claps2);
                            },
                            5, {
                                spawnResonator.();
                                ~spawner.suspend(parStream);
                            },
                            6, {
                                releaseResonator.();
                                //Pdefn(\plankFreq,  131 * 12 + Pwhite(-10, 10));
                                /*
                                spawnParPtn.(Pbind(
                                    \amp, Pbrown(0.6, 1),//Pbrown(0.2, 0.5),
                                    \bufnum, Pn(Plazy({ Pshuf(~t.handclaps) })),
                                    // \type, Pwrand([\note, \rest], [0.7, 0.3], inf),
                                    //XXX magic numbers
                                    \dur, Fdef(\pFuzzyBeatMatch).(~data.onset[419..427].flop[1], 5),
                                    \delta, Pkey(\dur)
                                ) <> claps);
                                */
                            },
                            7, {
                                //Duration of this part
                                var duration = 50;

                                spawnResonator.();
                                ~spawner.suspend(parStream);
                                //Parallell pattern, which continues after the main pattern has been silenced
                                //(see below)
                                //TODO: How can the duration of the parallel stream
                                //affect the length of the main stream?
                                //Maybe this part should be the last, always
                                /*
                                spawnParPtn.(
                                    Pfindur(duration + ev.dur, Pchain(
                                        Pbind(
                                            \instrument, \bufHandclaps,
                                            \outbus, Pfunc { ~t.fxOut },
                                            \bufnum, Pn(Plazy({ Pshuf(~t.handclaps) })) ,
                                            // \startPos, Pxrand(~data.onset.flop[0], inf),
                                            \amp, Pbrown(0.1, 1) * Pseg([1, 0.001], duration, \sine),
                                            // \test, Pfunc { "hello".postln },
                                            // \freq, Pdefn(\plankFreq),
                                            \sustain, 1,
                                            \group, Pfunc { ~t.mainGroup },
                                            \dur, Pn(Fdef(\pFuzzyBeatMatch).(~data.onset[419..426].flop[1], 4), 3)
                                        )
                                        // Pdef(\t08randomizedBeginning),

                                    ))
                                );
                                */
                            }
                        )
                    };
                    //Set curPart to current
                    curPart = ~data.currentPart;
                };
                ev = 0.yield;
            }

        }),
        \isFreqshift, Pfunc { |ev|
            var prob = (
                2: 0,
                4: 0.15,
                7: 0
            );
            ((ev.onset >= 3870) or: {
                #[120].includes(ev.onset)
            } or: {
                (prob[~data.currentPart] ? 0).coin
            });

            false
        },
        \durFactor, Pif(Pfunc { #[4].includes(~data.currentPart) }, Pgbrown(0.85, 1, 0.1), 1),
        //shorten last segment
        \durFactor, Pif(Pfunc { |ev| ev.onset == 427 }, 0.5, Pkey(\durFactor)),
        \dur, Pkey(\dur) * Pkey(\durFactor),
        // \fadetime, Pif(Pfunc { |ev| ~data.currentPart == 8 }, 2, 0.002),
        //\dur, Pkey(\dur) - 0.05, //TMP
        // \amp, 0,
        \instrument, Pif(Pkey(\isFreqshift), \diskSegmentFreqshift, \diskSegment),
        \ffreq, 6000,
        \freqshiftAmp, 2,

        \freqshift, Pswitch1([
            Pseg(Pseq([-4, -5000, -4, -800]), Pwhite(1,5) * 5, \exp, inf),
            // -4800 //Pseg(Pseries(28, Pwhite(1,2)).fold(1,11).midicps * -100, 5, \exp)

            Prand(-7.6875 * (1..16), inf),
            Plazy { Pgeom(1, 1.1.rrand(2.2)).fold(0, 100) - 1 }  * -7.6875,
            -7.6875 * Pwhite(1,4)
        ], Pfunc { |ev|
            case { ev.onset >= 3780 } {
                0
            } {#[0].includes(~data.currentPart)} {
                1
            } { ~data.currentPart == 3 } {
                2
            }{ true } {
                3
            }
        })
        // \amp, 0
        )


}));
// Ndef(\pitch, { SinOsc.ar("B3".namecps) * 0.1 }).play

// q.player.play
)

/*EOF*/
q.player.play

Pdefn(\plankFreq, 75 * Plazy(Pseries(1, 1, 3.rrand(7))))
Ndef(\sin, { SinOsc.ar(\freq.kr) * 0.1 }).play.gui

q.player.bounce((dur: 10))

~claps = "samples/handclaps/*.wav".resolveRelative.pathMatch.collect(Buffer.read(s, _));
(

Pdef(\test, Pbind(
    // \instrument, \bufSegment,
    \bufnum, Pxrand(~claps, inf),
    \outbus, 4,
    \instrument, Prand([\diskSegmentPlank], inf),
    // \bufnum, Pfunc { ~protoEvent.bufnum },
    // \startPos, Pfunc({ ~data.onset.flop[0][~currentEvent.onset.postln] }),
    \amp, 1,//Pbrown(0.2, 0.5),
    \dur, Pbrown(0.2, 0.4),
    \type, Pwrand([\note, \rest], [0.7, 0.3], inf),
    \legato, 1,
    \freq, 131 * Pwhite(8,12),
    // \group, Pfunc { ~t.mainGroup }
)).play
)


q.player.t.verb.set(\amp, 1);
q.player.t.verb.set(\time, 0.5)