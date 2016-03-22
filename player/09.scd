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
        \amp, Pseg2([1, 1, 0.001], Pseq([~data.onset.size * 3, 15]), \exp);
    ));

    ~onReady = {
        var wood2 = [[1.0, 1.777, 2.378, 3.377],		// Wood2
            [0.04, 0.01, 0.01, 0.008],
            [0.2, 0.15, 0.15, 0.3]];

		//FIXME: reverb params
		//This doesn't work with .bounce
		~t.reverb = Synth(\plate_reverb_2x2, [\amp, -38.dbamp, \decay, 0.1, \bandwidth, 1500, \predelay, 10], ~t.sendGroup);

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


// q.player.play;

q.player.bounce
)
