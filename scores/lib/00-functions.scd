q.make({

    //Setup factory, run from within Setup
    ~makeSetup = { arg sym, func, rebuildOn;
        currentEnvironment[sym] = Setup(func, rebuildOn);

        currentEnvironment[sym].makeAdd(q.settings[sym]);
    };

    //Make control ( Synth + Bus ),
    ~makeCtl = { arg sym, defName, args, channels=1, type=\control;
        var argfunc, busname = ("ctl_" ++ sym).asSymbol;
        q.bus.make  {
            currentEnvironment[busname] = Bus.perform(type, s, channels);
        };
        argfunc = { args ++ [\bus, q.bus[busname]] };
        q.ctl.make {
            // argf
            currentEnvironment[sym] = Synth.tail(q.grp.ctl, defName, argfunc.value);
        }
    };

    //Make fx ( Synth + Bus ),
    ~makeFx = { arg sym, defName, args, channels=2, type=\audio;
        var argfunc, busname = ("fx_" ++ sym).asSymbol;
        q.bus.make  {
            currentEnvironment[busname] = Bus.perform(type, s, channels);
        };
        argfunc = { args ++ [\bus, q.bus[busname]] };
        q.fx.make {
            // argf
            currentEnvironment[sym] = Synth.tail(q.grp.fx, defName, argfunc.value);
        }

    };

    ~smpLoad = { |sym, reload=true|
        var list, paths, full = PathName(q.path.samples +/+ sym);
        if (reload or: { q.buf[sym].isNil }) {
            if (full.isFolder) {
                paths = full.files.collect(_.fullPath); // all files in dir
            } {
                paths = (full.fullPath ++ ".*").pathMatch // all files starting with (sym ++ ".")
            };
            paths = paths.select(_.isSoundFile);
            if (paths.isEmpty) {
                ("Couldn't find any soundfiles at path" + sym).warn;
                nil
            }{
                q.buf[sym].free; // Free buffers;
                q.buf.make { currentEnvironment[sym] = paths.collect(Buffer.read(s, _)) };
            }
        } {
            q.buf[sym]
        }
    };



    //Pattern-generating buffer functions
    ~pBuf = { |sym|
        Pfuncn({ |ev|
            if(ev.isNil or: { ev.bufindex.isNil } ) {
                q.buf[sym]
            } {
                q.buf[sym] !? { q.buf[sym][ev.bufindex] }
            };
        }, inf);
    };

    ~pBufChoose = { |sym|
        Pfuncn({ |ev|
            q.buf[sym].choose
        }, inf);
    };

    ~pBufAt = { |sym, index|
        Pfuncn({ |ev|
            q.buf[sym].at(index % q.buf[sym].size)
        }, inf);
    };

    ~pBus = { |sym| Pfuncn({ q.bus[sym] }, inf) };

    ~pCtl = { |sym| Pfuncn({ q.ctl[sym] }, inf) };
    ~pCtlBus = { |sym| Pfuncn({ q.bus[(\ctl_ ++ sym).asSymbol] }, inf) };

    ~pFx = { |sym| Pfuncn({ q.fx[sym] }, inf) };
    ~pFxBus = { |sym| Pfuncn({ q.bus[(\fx_ ++ sym).asSymbol]}, inf) };



});

/*
q.smpLoad('banks/hits', false); //Loading, not reloading, samples
q.pBuf('banks/hits').asStream.next; // Get all samples
q.pBuf('banks/hits').asStream.next((bufindex:0)); // Get a specific sample
q.pBufAt('banks/hits', 2).asStream.next; // Get a specific sample, another way
q.pBufChoose('banks/hits').asStream.next; // Get a random sample
*/

