var songlist = #[1,2,3,4,7,8,9];
// var songlist = #[3,3,3];
var fallbackRandSeed = { 65536.rand };
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
    //action: { cond.unhang },
    //postAction runs after cleanup
    postAction: { |e, code|
        if (code.notNil and: { code > 0 }) {
            code.exit;
        } {
            cond.unhang;
        }
    };
    // sampleFormat: "float32"
);
var rend = { |o|
    fork {
        1.wait;
        o.action;
    }
};

var debug = (thisProcess.argv[2] == "1");

//If debug mode
if (debug) {
    options.dur = 10;
};



"lib/init".import;

fork {
    var nextName, randSeed;
    var backup = { |path|
        var newPath = path ++ ".bak";
        if (File.exists(newPath)) {
            backup.(newPath);
        };
        if (File.exists(path)) {
            "mv % %".format(path.quote, newPath.quote).systemCmd
        }
    };
    {
        randSeed = (thisProcess.argv[0] ? fallbackRandSeed).asInteger;

        thisProcess.argv[1] !? { |p| options.basePath = p };

        /*
        if (debug and: { File.exists(options.basePath) }) {
            "ok".postln;
            0.exit;
        }
        */
        //randSeed = 10000.rand;
        thisThread.randSeed = randSeed;




        backup.(options.basePath);

        "Creating directory at %".format(options.basePath).postln;
        options.basePath.mkdir;

        songlist.scramble.do { |song, i|

            var success = false;
            var tries = 3;

            //Import file
            var title = song.asStringToBase(10, 2);
            title.import;

            //Filename format: [num]_[title].wav
            options.path = options.basePath +/+ "%_%.wav".format((i + 1), title);

            "Rendering song % as %".format(q.player.song, options.path.basename).postln;
            //Loop if
            while { success.not and: { tries > 0 }} {
                tries = tries - 1;
                fork {
                    {
                        //This resets seed for setup code
                        thisThread.randSeed = randSeed;
                        //This sets seed for patterns and synths
                        //UGens are (currently) not completely deterministic:
                        //Would perhaps need separate randIDs for those
                        q.player.randSeed = randSeed;

                        //Quick fix for race conditions
                        //player sets scoreReady to true when all data is loaded
                        //clunky
                        while(q.player.scoreReady.not) {
                            0.01.wait;
                        };
                        q.player.bounce(options);
                    }.try({ |err|
                        err.reportError;
                        1.exit;
                    })
                };
                cond.hang;

                //Test that file hasn't exploded
                SoundFile.use(options.path, { |sf|
                    sf.channelPeaks
                    if (sf.channelPeaks.maxItem < -0.5.dbamp) {
                        success = true;
                    }
                });
                cond.hang;

            };

        };
        "Done".postln;
        0.exit;

    }.try({ |err|
        err.reportError;
        1.exit;
    });

}

