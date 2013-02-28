//Init paths and load all the other lib files.
//TODO: make it possible to use other interpreter variables
// (using this.interpret("whatever"))
{ arg settings;

    settings.postln;

    q !?  { q.freeAll };

    q = Setup({

        ~song = settings.song;
        ~settings = settings;

        ~path = ().make({
            //This is meant to be executed from main file, so
            //base is relative to that.
            ~base = "".resolveRelative;

            ~lib = ~base +/+ "lib";
            ~instr = ~base +/+ "Instr";
            ~patterns = ~base +/+ "patterns";
            ~samples = ~base +/+ "samples";
            ~data = ~base +/+ "data";

            Instr.dir = ~instr;
            Sample.dir = ~samples;
            SFP.dir = ~samples;
        });

        ~find = { arg what, path;
            q.path.at(what) +/+ path
        };

        topEnvironment.use({
            (q.path.lib +/+ "*").pathMatch
            .reject({ |x| x == thisProcess.nowExecutingPath })
            .do{ arg x;
                // x.postln;
                x.load;
            };
        });

        ~lastCall = Setup({"Done".postln}, \tree);


    })

};