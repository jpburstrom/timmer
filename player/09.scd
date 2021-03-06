//# Song 09 ###



//## Initialize ###
(
var handclapPaths = "samples/handclaps/*.wav".resolveRelative.pathMatch;

"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("09");
//q.player.extractFeatures;
// q.playerui.connect(q.player);
q.player.data.tail = 1.5;
q.player.monitorGain = 6.dbamp;
q.player.limiterLevel = -1.dbamp;
//Channel map: Bass, Fqshift/Claps, FM, Resonator, strange wood, Piezo (1ch)

q.player.use {

    var claps = Pn(Plazy { Pseq(~t.handclaps.scramble) }).asStream;


    //The arrays represent different types of onsets,
    //sound classes or whatever. They were created with the segment-grouping ui in lib/misc
    //group => index
    ~data.groups = [
        [ 0, 3, 6 ], //0
        [ 1, 5, 8 ], //1
        [ 2, 4, 7, 17, 28 ], //2
        [ 11, 14 ], //3
        [ 10, 27, 30 ], //4
        //        These were in group 8 earlier, shorter
        [ 12 ] ++ [ 15, 20, 22, 24, 26, 29 ], //5
        [ 9, 18 ], //6
        [ 13, 16, 19, 21, 23, 25 ],  //7
    ];

    //This is the original order of the groups
    //index => group
    ~data.groupscore = [ 0, 1, 2, 0, 2, 1, 0, 2, 1, 6, 4, 3, 5, 7, 3, 5, 7, 2, 6, 7, 5, 7, 5, 7, 5, 7, 5, 4, 2, 5, 4 ];

    q.player.data.groups.collect(_.size).reduce('*'); //Number of possible versions?

    //We use this data to create a new randomized version
    //going through ~data.groupscore but randomizing which group member it plays
    ~setIterator.(Pn(Prout({ |ev|
        var groups = ~data.groups.deepCopy;
        ~data.groupscore.do { |grp|
            // q.playerui.log(
            ev = groups[grp].remove(groups[grp].choose).yield;
        }
    }));
    );

    ~setPtn.(Pbind(
        \instrument, \diskSegment,
        //Play through 4 times, then fade
        // \amp, Pseg2([1, 1, 1], Pseq([~data.onset.size * 3, 5]), \sin),
        \amp, 1,
        \end, p { |ev|
            ~data.isEnding = false;
            (~data.onset.size * 3).do {
                ev = 1.yield;
            };
            ~data.isEnding = true;
            //4,5,7 = magic end onsets
            while { [4,5,7].includes(ev.onset).not } {
                ev = 1.yield;
            };
            ev = 1.yield; //Let onset play, and then finish
            nil.yield;

        },
    	\timingOffset, 0.1, //to sync with parPtn
        \startPos, Pkey(\startPos) - 0.01 //Fix bad segmentation
	));

	//Use ptpar to offset in time, to make sure ~currentEvent is accurate
	~parPtn = Ptpar([0.1, Pevent( Pbind(
        \instrument, \bufHandclaps,
        \bufnum, Pfunc( { claps.next } ),
        \outbus, Pfunc { ~t.mainOut },
		//Fade in, then
		\amp, Pseg([0.01, Pwhite(0.7, 1)], Pseq([20, Pn(3)]), \sin) * 3,
        \amp, p { |ev|
            loop {
                5.rrand(30).do {
                    ev = Rest(0).yield;
                };
                ev = (ev.amp * 0.1).yield;
            }
        },
        \break, Pfunc { 0.2.coin },
        \dur, Pif(Pkey(\break),
            Pfunc { Rest(~currentEvent.dur) },
            Fdef(\pBrownDurDivision).value(
                Pfunc { ~currentEvent.dur }, 0.2, 0.22, 0.01
        )),
        \test, Pif(Pfunc { ~data.isEnding }, nil, 1),
        \sustain, 1
    ), ~protoEvent),
	0.1, 	Pbind(
		\instrument, \fmGloss,
		\dur, Pwrand([Rest(15), Pfunc { ~currentEvent.dur }], [0.05, 0.95]),
		\sustain, Pwhite(1, 8.0),
        \test, Pif(Pfunc { ~data.isEnding }, nil, 1),
        \type, p {
			var resume;
            loop {
                //Wait 30-45 sec
				resume = thisThread.beats + 30.rrand(45);
				while { resume > thisThread.beats } {
					\rest.yield;
				};
				//a note, followed by 2-5 rests. Repeat 2-4 times
				2.rrand(4).do {
					\note.yield;
					2.rrand(5).do {
						\rest.yield;
					}
				}
			}
		},
        \root, 4,
		\octave, 4,
		\scale, Scale.dorian,
		\amp, Plprand(0.01, 0.1),
		\outbus, Pfunc { ~t.longRevBus },
		\timingOffset, Pwhite(0.0, 0.05),
		\group, Pfunc { ~t.mainGroup },
		\note, p {
			var prev, cur;
			var note = [ 0, 1, 3, 5, 7, 10, 12, 14, 17 ];
			loop {
				cur = note.scramble.keep(3);
				while {cur == prev} {
					cur = note.scramble.keep(3).sort;
				};
				if (~data.groupscore[~currentEvent.onset] == 5) {
					cur = cur.replace(14, 13)
				};
				cur.yield;
				prev = cur;
			}
		};
	)
	]);
	~onReady = {
        var compLookahead = 0.01;
        var revSize = 0.4;

        //FIXME: reverb params
        // ~t.reverb = Synth(\plate_reverb_2x2, [\amp, -38.dbamp, \decay, 0.1, \bandwidth, 1500, \predelay, 10], ~t.sendGroup);
        ~t.longRevBus = Bus.audio(s, 2);
		~t.reverb2 = Synth(\plate_reverb_2x2, [\amp, 0.dbamp, \outbus, ~t.fxOut, \decay, 1, \predelay, 0, \inbus, ~t.longRevBus], ~t.sendGroup);


        ~t.handclaps = handclapPaths.collect { |path|
            Buffer.read(s, path);
        };

       // ~t.mixin = Monitor().play(~t.mainOut.index, 2, ~t.fxOut.index, 2, ~t.postGroup, false, 0.01);
              //zap bad values before sending to verb
        ~t.zapper = Synth(\zapper, nil, ~t.mainGroup, \addToTail);

        ~t.wood = Synth(\wood09, [\inbus, ~t.mainOut, \outbus, ~t.fxOut], target:~t.postGroup);
        ~t.resonator = Synth(\resonator09, [\inbus, ~t.mainOut, \outbus, ~t.fxOut], target:~t.postGroup);

        //POST FX
        ~t.softclip = Synth(\softclip,
            [\outbus, ~t.fxOut, \pregain, 1, \amp, 1],
            ~t.postGroup, \addToTail);
         ~t.compressor = Synth(\compressor,
        [\outbus, ~t.fxOut, \thresh, 0.1, \ratio, 10, \attack, compLookahead, \release, 0.1, \amp, 1],
        ~t.postGroup, \addToTail);
        //zap bad values before sending to verb
        ~t.zapper = Synth(\zapper, nil, ~t.postGroup, \addToTail);

        //SEND FX
        ~t.verb = Synth(\jpverb,
            [\inbus, ~t.fxOut, \outbus, ~t.fxOut, \time, 0.1, \amp, 0.1, \damp, 0.4, \size, revSize],
            ~t.sendGroup, \addToTail);



    };

    //Turn on resonator whenever a group 5 onset is playing,
    //turning it off directly afterwards
    ~actions.onset.onStart = { |ev, num|
         //Middle long note
        if (~data.groups[5].includes(num) ) {
            ~t.resonator.set(\gate, 1);
            ~t.resonator.set(\freq, 88 * 2.rrand(6));
            // ~t.resonator.set(\amp, 0.1.rrand(1));
        } {
            ~t.resonator.set(\gate, 0);
        }
    }

};


// q.player.play

// q.player.bounce
)

/*EOF*/

q.player.play

q.player.t.verb.set(\amp, 0.1)