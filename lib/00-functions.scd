q.make({

    //Setup factory, run from within Setup
    ~makeSetup = { arg sym, func, rebuildOn;
        currentEnvironment[sym] = Setup(func, rebuildOn);
        currentEnvironment[sym].makeAdd(q.settings[sym]);
    };

    ~makeSpec = { arg sym, spec;
        ControlSpec.specs[sym] = spec.asSpec;
    };

    (q.path.lib +/+ "helpers/synthDefFactory.scd").load;

    //Make control ( Synth + Bus ),
    ~makeCtl = { arg sym, defName, args, channels=1, type=\control;
        var argfunc, busname = ("ctl_" ++ sym).asSymbol;
        q.bus[busname].free;
        q.bus.make  {
                currentEnvironment[busname] = Bus.perform(type, s, channels);
        };
        argfunc = { [\bus, q.bus[busname], \outbus, q.bus[busname]] ++ args.value };

        q.ctl.make {
            // argf
            currentEnvironment[sym] = Synth.tail(q.grp.ctl, defName, argfunc.value);
        };
        //Placeholder OSCdef
        // OSCdef(busname,'/tr', s.addr, nil, [{ arg id; id == q.ctl[sym].nodeID}]);

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



    //Pattern-generating buffer functions, BIG HACKS
    ~pBuf = { |sym|
        Pfsym(sym, { q.buf }).collect({ | val, ev |
            if(ev.isNil or: { ev.bufindex.isNil } ) {
                val
            } {
                val !? { val[ev.bufindex] }
            };
        })
    };

    ~pBufChoose = { |sym|
        Pfsym(sym, { q.buf }).collect({ |val| val.choose })
    };

    ~pBufAt = { |sym, index|
        Pfsym(sym, { q.buf }).collect({ |val| val[index % val.size] })
    };

    ~pBufBankSize = { |sym|
        Pfsym(sym, { q.buf }).collect({ |val| val.size })
    };

    ~pBus = { |sym| Pfsym(sym, { q.bus }) };

    ~pCtl = { |sym| Pfsym(sym, { q.ctl }) };
    ~pCtlBus = { |sym| Pfsym((\ctl_ ++ sym).asSymbol, { q.bus } ) };

    ~pFx = { |sym| Pfsym(sym, { q.fx }) };
    ~pFxBus = { |sym| Pfsym((\fx_ ++ sym).asSymbol, { q.fx } ) };



});

/*
q.smpLoad('banks/hits', false); //Loading, not reloading, samples
q.pBuf('banks/hits').asStream.next; // Get all samples
q.pBuf('banks/hits').asStream.next((bufindex:0)); // Get a specific sample
q.pBufAt('banks/hits', 2).asStream.next; // Get a specific sample, another way
q.pBufChoose('banks/hits').asStream.next; // Get a random sample
*/

