//Init paths and load all the other lib files.

{ arg song;

    q !?  { q.freeAll };

    q = Setup({

        ~song = song;

        ~path = ().make({
            ~base = "".resolveRelative.dirname;
            ~lib = ~base +/+ "lib";
            ~instr = ~base +/+ "Instr";
            ~patterns = ~base +/+ "patterns";
            ~samples = ~base +/+ "samples";
            ~data = ~base +/+ "data";

            Instr.dir = ~instr;
            Sample.dir = ~samples;
            SFP.dir = ~samples;
        });

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



}.value(~song);



q

