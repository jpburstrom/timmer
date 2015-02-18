var init = { |settings|
    q !?  {
        q.updaters.do(_.remove);
        q.launchPad !? {
            q.launchPad.allElements.do(_.reset);
            q.launchPad.free;
        };
        q.free

    };
    KeyDownActions.globalShortcutsEnabled = false;

    s.options.sampleRate = 48000;
    s.options.hardwareBufferSize = 256;

    q = Setup({
        s.latency.wait;

        ~song = "live";
        ~settings = settings;
        ~settings.latencies = List();
        /*
        if (s.options.device == "PreSonus FireStudio") {
            ~settings.latencies.add(0.00425); //extra hardware latency
        };
        ~settings.latencies.add(((s.options.hardwareBufferSize ? 512) * 2) / s.sampleRate);
        */

        //Assuming hardwareBufferSize = 256;
        ~settings.latencies.add(0.014708333);

        //Safety limiter, see brstrm/StageLimiter.sc
        if (true) {
            StageLimiter.activate;
            ~settings.latencies.add(0.02); //For StageLimiter,
            //see Limiter help -- adds double amount of latency
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

        ~updaters = ();

        ~storage = Object.readArchive(q.path.data +/+ "storage.archive") ?? {
            MultiLevelIdentityDictionary.new;
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

        ~forceReload = { init.( q.settings.make { ~basePath = q.path.base } ) };


    });
    //Fix
    Toolbar.replace('-Live-');
    Toolbar.replace('Init', { init.( q.settings.make { ~basePath = q.path.base } ) });
    //Toolbar.replace('Store', { "Writing file".postln; q.store.writeToFile });
    Toolbar.replace('NdefMixer', { NdefMixer(s) });
};

init;