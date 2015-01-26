Spec.add(\preamp, [-30, 30, \lin, 0, 0]);
Knob.defaultMode = \vert;
q.make {
    var preampPath = q.path.data +/+ "preamps.data.scd";
    var c;
    //TODO: clean up open windows
    ~conds = ();
    ~cvs = ();

    //PREAMPS
    c = Conductor.make({ |con |
        /*
        ~np = NodeProxy.audio(s);
        con.nodeProxy_(~np, [amp: preamp]);
        ~np.source = { SinOsc.ar(440, mul: \amp.kr) * 0.05 };
        con.name = "Example";
        */
        con.useSettings;
        con.gui[\settingsGUI] = { |win, name =">", settings|
            ~simpleButton.value(win)
            .states_([["S"]])
            .action_( { settings.save( preampPath );  });
            ~simpleButton.value(win)
            .states_([["O"]])
            .action_( { settings.load( preampPath ); });
            ~simpleButton.value(win)
            .states_([["SA"]])
            .action_( { settings.save( );  });
            ~simpleButton.value(win)
            .states_([["OA"]])
            .action_( { settings.load( ); });
        };
    });
    //TODO: 36->93 as global var
    q.settings.pitches.collect { |i| c.addCV((i).asSymbol, 1, \knob).spec_(\preamp) };
    c.gui.keys = q.settings.pitches.collect({ |i|
        var sym = (i).asSymbol;
        ~cvs[sym] = c[sym];
        sym
    }).clump(12);
    c.load(preampPath);
    defer {
        Toolbar.replace('Preamps', { c.gui[\win] !? { c.gui[\win].close; }; c.show });
    };
    ~conds.preamp = c;
};