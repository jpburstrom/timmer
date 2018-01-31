//# Template for songs ###

//## Initialize ###
(
var relPath = "".resolveRelative;
var handClapPaths = "samples/handclaps/*.wav".resolveRelative;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("08");
//q.player.extractFeatures;
// q.playerui.connect(q.player);
// q.markov = "/lib/protos/markov-trainer".import;

//onReady is called when player buffer is loaded, and before playing
//It's called within a routine, so we can use s.sync, .wait or similar

//Channel map: Bass, Resonator, Handclap, Rev, Piezo



q.player.onReady = {
    var compLookahead = 0.01;
    var revSize = 0.1;

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
        [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \time, 0.2, \amp, 0.4, \damp, 0.9, \size, revSize],
        ~t.sendGroup, \addToTail);

    //XXX tmp
    //~t.monitor.fx.vol = 0;
};


q.player.use {

    ~data.endSegment = 360.rrand(370);

    ~data.grouping = #[
        //Part one, onset groups
        [ 0, 1, 2, 3, 1, 4, 5, 1,
            6, 7, 1, 7, 8, 9, 7, 10,
            7, 11, 12, 13, 7, 12, 14, 9,
            15, 7, 12, 14, 16, 17 ]
    ];

    ~data.iterators = [
        //Scramble order of first part, but don't put two in the same group after each other
        //0
        Plazy { Pseq(Fdef(\scrambleAvoidSimilar).(~grouping[0])) },
        //1
        Pseries(30, 1, 34),
        //2
        Plazy {
            Pseq((64..76).scramble)
            ++ Pseq((77..80))
            //This is a bit
            ++ Pwalk((81..90), Pwrand([-2, 1, 2], [0.3, 0.4, 0.4], 30.rrand(50)))
        },
        //3
        Pseq((91..105)),
        //4
        Pseq((106..218)),
        //5
        Pseq((219..301)),
        //6
        Pseries(302, 1, ~endSegment - 302)
        //7


        // ~p7 = Pn(0);
    ];

    //Pattern with shuffled parts
    //sets ~data.currentPart
    ~setIterator.value(Pshuf(Array.series(~data.iterators.size)).collect { |index|
        ~data.currentPart = index;
        ~data.iterators[index];
    });
};



//## Patterns #######

//This sets a pattern used to modify the base player pattern.

//TODO use score-player callback instead!!!




q.player.setPtn(Plazy({

    Pbind(
        //\startPos, Pkey(\startPos) - 0.002,
        \timingOffset, 0.05,
        \dummy, Prout({ |ev|

            var blacklist = (118..122) ++ (134..139) ++ (175..186) ++ (192..199),
            claps = Pbind(
                \instrument, \bufHandclaps,
                \outbus, Pfunc { ~t.fxOut },
                \bufnum, Ppatlace([Rest(), Rest(), Pshufn(~t.handclaps, inf) }),
                \amp, Pn(2, 1),
                \delta, Pfunc { ~nextEvent.dur },
                \timingOffset, Pwhite(-0.02, 0.02),
                \group, Pfunc { ~t.mainGroup }
            ),
            claps2 = Pset(\amp,
                Pif(Pfunc { blacklist.includes(ev.onset).not and: { 0.7.coin } },
                Pn(2, 1), Rest()),
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


            if (~data.currentPart != curPart) {

                if {~data.currentPart < 4) {
                    //First 4 parts are similar, only start resonator and stream
                    //if we're arriving from somewhere else
                    if (curPart > 3) {
                        spawnResonator.();
                        spawnParPtn.(claps);
                    }
                } {
                    ~data.currentPart.switch(
                        4, {
                            freeResonator.();
                            spawnParPtn.(claps2);
                        }
                        5, {
                            freeResonator.();
                            ~spawner.suspend(parStream);
                        },
                        6, {
                            freeResonator.();
                            Pdefn(\plankFreq,  131 * 12 + Pwhite(-10, 10));
                            spawnParPtn.(Pbind(
                                \bufnum, Pshufn(~t.handclaps, inf),
                                \outbus,Pfunc { ~t.fxOut },
                                \instrument, Prand([\diskSegmentPlank], inf),
                                \amp, 1,//Pbrown(0.2, 0.5),
                                \type, Pwrand([\note, \rest], [0.7, 0.3], inf),
                                //XXX magic numbers
                                \dur, Fdef(\pFuzzyBeatMatch).(~data.onset[301..368].flop[1], 5),
                                \legato, 1,
                                \freq, Pdefn(\plankFreq),
                                \group, Pfunc { ~t.mainGroup }
                            ));
                        },
                        7, {
                            //Duration of this part
                            var duration = 40.rrand(55);

                            spawnResonator.();
                            ~spawner.suspend(parStream);
                            //Parallell pattern, which continues after the main pattern has been silenced
                            //(see below)
                            //TODO: How can the duration of the parallel stream
                            //affect the length of the main stream?
                            //Maybe this part should be the last, always
                            ~spawner.par (
                                Pfindur(duration + ev.dur, Pchain(
                                    Pbind(
                                        \instrument, \bufSegmentHandclaps,
                                        \outbus, Pfunc { ~t.fxOut },
                                        \bufnum, Pfunc { claps.next },
                                        // \startPos, Pxrand(~data.onset.flop[0], inf),
                                        \amp, Pkey(\amp) * 1,
                                        // \test, Pfunc { "hello".postln },
                                        \freq, Pdefn(\plankFreq),
                                        \sustain, 1,
                                        \group, Pfunc { ~t.mainGroup }
                                    ),
                                    Pdef(\t08randomizedBeginning)

                                )),
                            );

                        }
                    )
                };
                //Set curPart to current
                curPart = ~data.currentPart;
            }

        }),
        //TEMP: Shorten last non-freqshifted note, so we don't get start of next attack
        \dur, Pif(Pkey(\onset) == (~endSegment ? 0), Pkey(\dur) - 0.05, Pkey(\dur)),
        //\dur, Pkey(\dur) - 0.05, //TMP
        // \amp, 0,
        \instrument, Pif(Pkey(\onset) < 370, \diskSegment, \diskSegmentFreqshift),
        //\outbus, Pseq([0, 2], inf),
        \freqshift, -5000.rrand(-8000),
        )

}));

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