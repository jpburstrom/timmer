var init = { |settings|
    q !?  { q.free };
    KeyDownActions.globalShortcutsEnabled = false;

    s.options.sampleRate = 48000;
    s.options.hardwareBufferSize = 128;

    q = Setup({
        s.latency.wait;

        ~song = "live";
        ~settings = settings;
        ~settings.latencies = List();
        if (s.options.device == "PreSonus FireStudio") {
            ~settings.latencies.add(0.00425); //extra hardware latency
        };
        ~settings.latencies.add(((s.options.hardwareBufferSize ? 512) * 2) / s.sampleRate);

        //Safety limiter, see brstrm/StageLimiter.sc
        if (true) {
            StageLimiter.activate;
            ~settings.latencies.add(0.01); //For StageLimiter;
        };

        ~path = ().make({
            //This is meant to be executed from main file, so
            //base is relative to that.
            ~base = settings.basePath ?? { "live".resolveRelative };

            ~lib = ~base +/+ "lib";
            ~patterns = ~base +/+ "patterns";
            ~samples = ~base +/+ "samples";
            ~data = ~base +/+ "data";
            ~storage = ~data +/+ "store-" ++ q.song.asString ++ ".zarchive";
        });

        ~find = { arg what, path;
            q.path.at(what) +/+ path
        };

        //Load all
        topEnvironment.use({
            (q.path.lib +/+ "*").pathMatch
            .reject({ |x| x == thisProcess.nowExecutingPath })
            .do{ arg x;
                // x.postln;
                x.load;
            };
        });


        ~lastCall = Setup({"Done".postln}, \tree);



    });
    //Fix
    Toolbar.replace('-Live-');
    Toolbar.replace('Init', { init.( q.settings.make { ~basePath = q.path.base } ) });
    Toolbar.replace('Store', { "Writing file".postln; q.store.writeToFile });
Toolbar.replace('NdefMixer', { NdefMixer(s) });
};

init;