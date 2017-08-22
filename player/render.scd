var songlist = #[1,2,3,4,7,8,9];
// var songlist = #[3,3,3];
var fallbackRandSeed = { 999.rand };
var cond = Condition();
var titles = (
    1: "Room Modes",
    2: "Gray on Gray",
    3: "348",
    4: "Alternate Take",
    7:  "Out of Band",
    8: "Cheek to Cheek",
    9: "Bass, Handclap, Synthesizer"
);
var options = (
    // dur:10, //debug
    sampleRate:96000,
    basePath: ("../render/" ++ Date.getDate.stamp ).resolveRelative,
    path: { |ev| ev.basePath +/+ "%_%.wav".format(~song, titles[~song.asSymbol]) },
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

fork {
    var randSeed;
    randSeed = thisProcess.argv[0] ? 12345.debug("Random seed");
    thisThread.randSeed = randSeed;
    options.basePath = "../render/%".format(randSeed.asString).resolveRelative;

    "Creating directory at %".format(options.basePath).postln;
    options.basePath.mkdir;


    songlist.scramble.do { |song, i|

        //Import file
        song.asStringToBase(10, 2).import;

        //Filename format: [num]_[title].wav
        options.path = options.basePath +/+ "%_%.wav".format((i + 1), titles[song]);

        "Rendering song % as %".format(q.player.song, options.path.basename).postln;
        fork {
            //This resets seed for setup code
            thisThread.randSeed = randSeed;
            //This sets seed for patterns and synths
            //UGens are (currently) not completely deterministic:
            //Would perhaps need separate randIDs for those
            q.player.randSeed = randSeed;
            q.player.bounce(options);
        };
        cond.postln.hang;

    };

    "Done".postln;
}
