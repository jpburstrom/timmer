var songlist = thisProcess.argv;
// var songlist = [9,10];
var current;
var songs;
var cond = Condition();
// ~songs.do(_.free);
var options = (
    // dur:1,
    basePath: ("../render/" ++ Date.getDate.stamp ).resolveRelative,
    path: { |ev| ev.basePath +/+ ~song ++ ".wav" },
    action: { cond.unhang };
);
var rend = { |o|
    o.postln;
    fork {
        1.wait;
        o.action;
    }
};
"lib/init".import;
"Creating directory at %".format(options.basePath).postln;
options.basePath.mkdir;
songs = ~songs = ();
fork {
    songlist.do { |song|
        var num = 1;

        //Import file
        song.asStringToBase(10, 2).import;

        if (song == 4) {
            num = 3;
            q.player.song = "04_%".format(1);
        };

        num.do { |i|
            "Rendering song %".format(q.player.song).postln;
            1.wait;
            fork {
                q.player.bounce(options);
            };
            // rend.value(options);
            cond.postln.hang;
            q.player.song = "%_%".format("04", i+2)
        }

    };
}
