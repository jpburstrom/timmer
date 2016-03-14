//# Template for songs ###

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
        //Play through, then start over and fade
        \amp, Pseg([1, 1, 0.001], Pseq([~data.onset.size, 15]), \exp);
    ));

    ~onReady = {
        var wood2 = [[1.0, 1.777, 2.378, 3.377],		// Wood2
            [0.04, 0.01, 0.01, 0.008],
            [0.2, 0.15, 0.15, 0.3]];

        //FIXME: reverb params

        //This doesn't work with .bounce
        ~t.reverb = Synth(\plate_reverb_2x2, [\amp, -38.dbamp, \decay, 0.1, \bandwidth, 1500, \predelay, 10], ~t.sendGroup);

        ~t.wood = {
            var snd = In.ar(0, 2);
            var x;
            // snd = BPF.ar(snd, 88, 0.001);
            /*
            6.do {
            var drone = BPF.ar(snd, 88 * 0.95.rrand(1.06), 0.09);
            11.do { drone = AllpassN.ar(drone, 0.1, 0.001.rrand(0.005), 4) };
            snd =  snd + drone;

            };
            */

            x = FreqShiftAA.ar(snd, -800);
            x = Klank.ar(`wood2, x * LFNoise2.ar(1).exprange(0.001, 2), 99, 0, 4) * 2;

            ReplaceOut.ar(0, x + snd);
        }.play(target:~t.postGroup);

        ~t.resonator = { |freq=88|
            var snd = In.ar(0, 2);
            snd = snd * EnvGen.ar(Env.asr(0.5, 1, 0.5), \gate.kr(0));
            snd = AllpassN.ar(BPF.ar(snd, freq, 0.1), 0.05, 88.reciprocal, 10) * \amp.kr(1);
            Out.ar(0, snd * 3);
        }.play(target:~t.postGroup);


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


q.player.play;

)
q.player.stop

