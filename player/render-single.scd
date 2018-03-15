var songlist = thisProcess.argv.drop(-1);
var randSeed = thisProcess.argv.last.asInteger;
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
        // var num = 1;

        //Import file
        song.import;
        "Rendering song % as %".format(q.player.song, options.path.basename).postln;
        fork {
            {
                //This resets seed for setup code
                thisThread.randSeed = randSeed;
                //This sets seed for patterns and synths
                //UGens are (currently) not completely deterministic:
                //Would perhaps need separate randIDs for those
                q.player.randSeed = randSeed;
                q.player.bounce(options);
            }.try({ |err|
                err.reportError;
                1.exit;
            })
        };
        cond.hang;

    };
}
