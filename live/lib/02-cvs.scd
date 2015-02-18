//leftover from trying out conductor. Eventually move to gui/reset
Spec.add(\preamp, [0, 15, \lin, 0, 0]);
Knob.defaultMode = \vert;
q.make {
    var preampPath = q.path.data +/+ "preamps.data.scd";
    var c;
    //TODO: clean up open windows

    //PREAMPS
    c = Conductor.make({ |con |
        /*
        ~np = NodeProxy.audio(s);
        con.nodeProxy_(~np, [amp: preamp]);
        ~np.source = { SinOsc.ar(440, mul: \amp.kr) * 0.05 };
        con.name = "Example";
        */
        con.useSettings(false);
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
           //q { settings.load( preampPath ) }.try( { "Error loading preamp presets".warn } );

        };

    });
    q.settings.pitches.collect { |i| c.addCV((i).asSymbol, 1, \knob).spec_(\preamp) };
    c.gui.keys = q.settings.pitches.collect({ |i|
        var val, sym = (i).asSymbol;

        //Add phase cvs
        val = (~storage[\cvs, \phase, sym] ?? {
            ~storage[\cvs, \phase, sym] = CV([0, 10].asSpec, 0.8)
        }).value;

        ~storage[\cvs, \phase, sym].spec_([0, 5].asSpec, val);

        ~storage[\cvs, \preamp, sym] !? {
            c[sym].value = ~storage[\cvs, \preamp, sym].value;
        };

        ~storage[\cvs, \preamp, sym] = c[sym];
        sym

    }).clump(5).flop;
    //~conds.preamp = c;

};


