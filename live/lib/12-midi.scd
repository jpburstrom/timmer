(
q.dev !? { |d| d.lpIn !? { |in|
    in.allElements.do(_.reset);
    in.free;
}};
q.make {
    //launchPad key mapping
    var keys = (
        snapshots: (0..3),
        macros: [0,8,16] +.x (4..7),
        modulation: [0,8] +.x (8..11) ++ (24..39),
        notes: [40,48,56] +.x (0..7)
    );
    var colors = (
        snapshots: [\off, \lRed, \red],
        macros: [\off, \lAmber, \amber],
        modulation: [\off, \yellow, \yellow]
    );

    ~dev = ();
    ~views = ();
    ~ctrls = ();

    ~dev.lpIn = MKtl('lnch0');
    ~dev.lpOut = LaunchpadOut(~dev.lpIn).reset;

    //TEMP reload everything on button press
    ~dev.lpIn.elementAt(\mixer).action_({ |elem|
        if (elem.value == 1) {
            defer { q.forceReload }
        }
    });

    //Auto-flash ON
    ~dev.lpOut.midiOut.control(0, 0, 40);

    ~ctrls.notes = q.f.getProto(\noteController).connect(~dev.lpIn, keys.notes);
    ~views.notes = q.f.getProto(\noteView).connect(~ctrls.notes, ~dev.lpOut);

    [\snapshots, \macros, \modulation].do { |k|
        ~ctrls[k] = q.f.getProto(\buttonController).connect(~dev.lpIn, keys[k]);
        ~views[k] = q.f.getProto(\buttonView).connect(~ctrls[k], ~dev.lpOut);
        ~views[k].colors = colors[k];
    };

    //modulation keys should always be inited
    ~ctrls.modulation.isKeyInited = { true };

    //=========SNAPSHOTS==============//

    ~ctrls.snapshots.use {
        ~onLongPress = { |k|
            q.snapshots.save(k);
        };
        ~onShortPress = { |k|
            q.snapshots.load(k);
        }
    };

    keys.snapshots.do { |x|
        if (q.snapshots.exists(x)) {
            ~ctrls.snapshots.setState(x, 1);
        }
    };

    //=========MACROS=============//

    //Go through macros and activate slots accordingly

    12.do { |i|
        if (~macros.exists(i)) {
            ~ctrls.macros.setState(i, 1);
        }
    };

    //Make macros update on macro updates
    ~macros.addDependant(~ctrls.macros);
    ~ctrls.macros.use {
        ~update = e { |obj, what, k, v|
            if (what == \put) {
                if (v.notNil) {
                    ~setState.(k, 1);
                } {
                    ~setState.(k, 0);
                }
            }
        };
    };



    //Run on button
    ~ctrls.macros.onButtonDown = { |k|
        ~macros.run(k);
    }.inEnvir;

    //========MODULATION========//

    //Button connects currently selected keys to a slot in the mod matrix
    //onButtonPress: |y|
    //~ctrls.notes.selected().do { |x| ~matrix.mod.add(x, y) }

    ~ctrls.modulation.use {

        //TODO: move connections to q.storage[\matrix, \modulation]
        ~connections = q.f.getProto(\connections);


        //TODO toggle on/off ffs
        ~onShortPress = { |to|
            to.postln;
            q.ctrls.notes.doSelected({ |from|
                ~connections.add(from, to);
            }.inEnvir);
        };

        //TODO: make connections on connection changes
    };

    //------------NOTES------------//

    //Unselect
    q.dev.lpIn.elementAt(\ar, 7).action_({
        ~ctrls.notes.doSelected(~unselect.(_), {})
    }.inEnvir);

    q.updaters.launchSynth = Updater(~launchController, { |what, msg, index, value, other|
        index = q.settings.pitches[index];
        index.postln;
        switch(value)
        {0} {
            q.releaseBandySynth(index);
        }
        {1} {
            q.createBandySynth(index);
        }
    });

}

);
/*
v = q.f.getProto(\buttonController)
v.connect(MKtl('lnch0'), [0,1,2,3])
*/
