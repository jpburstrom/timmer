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
        2.wait;

        ~song = "live";
        ~settings = settings;
        ~settings.paramLists = (
            global: { #[pitch, delay, rev, amp, lfoSpeed,
                lfoDepth, noiseSpeed, noiseDepth] },
            modTop: { |ev| [#[pedal, amp], ev.global].allTuples },
            modLFO: {
                #[ lfo, [ pitch, delay, noiseSpeed, noiseDepth ]].allTuples ++
                #[ noise, [ pitch, delay, lfoSpeed, lfoDepth ] ].allTuples
            },
            mod: { |ev| ev.modTop ++ ev.modLFO }
        );
        ~settings.latencies = List();
        //TODO: device dictionary
        if (s.options.device == "PreSonus FireStudio") {
            //Assuming hardwareBufferSize = 256;
            ~settings.latencies.add(193 / s.sampleRate);
        } {
            if (s.options.device.beginsWith("Babyface")) {
                ~settings.latencies.add(139 / s.sampleRate);

            } {
                "Latency for device '%' unknown. Please check init.scd.".format(s.options.device).warn;
            }
        };
        //Multiply latency with 2 (roundtrip)
        ~settings.latencies.add(((s.options.hardwareBufferSize ? 512) * 2) / s.sampleRate);
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

        //Reload everything
        ~forceReload = { init.( q.settings.copy.make { ~basePath = q.path.base } ) };


    });
    //Fix
    Toolbar.replace('-Live-');
    Toolbar.replace('Init', { init.( q.settings.copy.make { ~basePath = q.path.base } ) });
    //Toolbar.replace('Store', { "Writing file".postln; q.store.writeToFile });
    Toolbar.replace('NdefMixer', { NdefMixer(s) });
};

init;