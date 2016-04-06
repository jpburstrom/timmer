//# Song 09 ###

//## Initialize ###
(
"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("09");
//q.player.extractFeatures;
q.playerui.connect(q.player);

q.player.use {

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
        //Play through 4 times, then fade
        \amp, Pseg2([1, 1, 0.001], Pseq([~data.onset.size * 3, 15]), \exp),
		\timingOffset, 0.1, //to sync with parPtn
		// \test, Pfunc { |ev| ~data.groupscore[ev.onset].postln; 2 }
	));

	//Use ptpar to offset in time, to make sure ~currentEvent is accurate
	~parPtn = Ptpar([0.1, Pevent( Pbind(
		\instrument, \bufSegmentFreqshift,
		\freqshift, -1000,
		//Fade in, then
		\amp, Pseg([0.01, Pwhite(0.7, 1)], Pseq([20, Pn(3)]), \exp),
		\dur, Fdef(\pBrownDurDivision).value(
			Pfunc { ~currentEvent.dur }, 0.4, 0.6, 0.05
		),
		\startPos, Pxrand(~data.onset.flop[0], inf)
	), ~protoEvent),
	0.1, 	Pbind(
		\instrument, \fmGloss,
		\dur, Pwrand([Rest(15), Pfunc { ~currentEvent.dur }], [0.05, 0.95]),
		\sustain, Pwhite(1, 8.0),
		\type, p {
			var resume;
			loop {
				//Wait 30-45 sec
				resume = thisThread.beats + 30.rrand(45);
				while { resume > thisThread.beats } {
					\rest.yield;
				};
				//a note, followed by 2-5 rests. Repeat 4-9 times
				3.rrand(6).do {
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
		\amp, Plprand(0.001, 0.01),
		\out, Pfunc { ~t.longRevBus },
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

		//FIXME: reverb params
		~t.reverb = Synth(\plate_reverb_2x2, [\amp, -38.dbamp, \decay, 0.1, \bandwidth, 1500, \predelay, 10], ~t.sendGroup);

		~t.longRevBus = Bus.audio(s, 2);
		~t.reverb2 = Synth(\plate_reverb_2x2, [\amp, 0.dbamp, \decay, 1, \predelay, 0, \inbus, ~t.longRevBus], ~t.sendGroup);
		~t.mixin = { In.ar(~t.longRevBus, 2) }.play(~t.postGroup);

        ~t.wood = Synth(\wood09, target:~t.postGroup);
		~t.resonator = Synth(\resonator09, target:~t.postGroup);


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

q.player.bounce
)
