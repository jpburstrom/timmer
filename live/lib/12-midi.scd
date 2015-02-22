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
        snapshots: [\off, \lRed, #[fRed, red]],
        macros: [\off, \lAmber, #[fAmber, amber]],
        modulation: #[off, lAmber, yellow]
    );

    var mktl;

    ~dev = ();
    ~views = ();
    ~ctrls = ();

    ~dev.lpIn = mktl = MKtl('lnch0');
   if (~dev.lpIn.mktlDevice.notNil) {

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
        [snapshots: \snapshotController,
            \macros: \macroController,
            \modulation: \modulationController ].pairsDo { |k, v|
            ~ctrls[k] = q.f.getProto(v).connect(~dev.lpIn, keys[k]);
            ~views[k] = q.f.getProto(\buttonView).connect(~ctrls[k], ~dev.lpOut);
            ~views[k].colors = colors[k];
        };


        //Snapshot activation

        keys.snapshots.do { |x|
            if (q.snapshots.exists(x)) {
                ~ctrls.snapshots.setState(x, 1);
            }
        };

        //Go through macros and activate slots accordingly

        12.do { |i|
            if (~macros.exists(i)) {
                ~ctrls.macros.setState(i, 1);
            }
        };


        //TODO: make modulation connections on connection changes

        //------------NOTES------------//

        //------- LAUNCHPAD RIGHT COLUMN ----------
        //E -- Remove all connections
        (
            3: [\yellow, {
                q.storage[\matrix, \modulation].allConnections.size.honk;
            }],
            4: [\red, e {
                ~ctrls.modulation.unselectAll;
            }],
            7: [\red, e {
                ~ctrls.notes.doSelected(~unselect.(_), {})
            }],
        ).keysValuesDo { |k, arr|
            q.dev.lpOut.setArrowColor(k, arr[0]);
            q.dev.lpIn.elementAt(\ar, k).action_(arr[1]);
        }
    };

    q.updaters.launchSynth = Updater(~launchController, { |what, msg, index, value, other|
        index = q.settings.pitches[index];
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
