//leftover from trying out conductor. Eventually move to gui/reset
Spec.add(\preamp, [0, 15, \lin, 0, 0]);
Spec.add(\pitch, [-2, 2, \lin, 0, 0]);

Knob.defaultMode = \vert;
q.make {
    var preampPath = q.path.data +/+ "preamps.data.scd";
    var locals, c;
    //TODO: clean up open windows

    //Add CV if not exist in storage already
    var maybeAddCV = { |path, spec|
        var val, cv = ~storage.atPath(path);
        if (cv.isNil) {
            ~storage.putAtPath(path, CV(spec));
        } {
            //Set spec for cv anyways
            val = cv.value;
            cv.spec_(spec);
            cv.value = val;
        }
    };

    //-------------A container for SimpleControllers--------

    ~simpleContainer = q.f.getProto(\simpleContainer);


    //--------------GLOBAL CVS--------------

    //Master CVs
    (
        pitch: \pitch,
        delay: \bipolar,
        rev: \unipolar,
        amp: \amp.asSpec.default_(1),
        lfoSpeed: \lofreq,
        lfoDepth: \unipolar,
        noiseSpeed: \lofreq,
        noiseDepth: \unipolar,
    ).keysValuesDo { |k, spec| maybeAddCV.([\cvs, \global, k], spec); };

    //Modulation
    ~settings.paramLists.modTop.do { |tup|
        var from, to;
        #from, to = tup;
        maybeAddCV.([\cvs, \modulation, from, to], \bipolar);
    };

    //LFO Modulation
    ~settings.paramLists.modLFO.do { |tup|
        var from, to;
        #from, to = tup;
        maybeAddCV.([\cvs, \modulation, from, to]);
    };

    24.do { |i|
        var sym = i.asSymbol;
        maybeAddCV.([\cvs, \macros, sym]);
    };

    //--------------LOCAL CVS----------------

    //key->spec map
    locals = (
        phase: [0, 1].asSpec,
        //almost like \delay.asSpec but 0 == 0
        delay: [0, 1, 9].asSpec,
        //TODO: Fix this.
        amp: [-12.dbamp, 12.dbamp, \exp, 0, 1].asSpec

    );

    //Create CVs for all keys
    q.settings.pitches.do({ |i|
        var sym = i.asSymbol;
        locals.keysValuesDo { |key, spec|
            maybeAddCV.([\cvs, key, sym], spec)
        };


    });

    //------------Matrixes---------------

    q.storage[\matrix, \modulation] = q.f.getProto(\connections);
    q.storage[\matrix, \fm] = q.f.getProto(\connections);

    //------------------------------------

    //---------PREAMPS--------------
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

    //Add preamp CVS to conductor
    c.gui.keys = q.settings.pitches.collect({ |i|
        var sym = i.asSymbol;

        c.addCV(sym, 1, \knob).spec_(\preamp);

        ~storage[\cvs, \preamp, sym] !? {
            c[sym].value = ~storage[\cvs, \preamp, sym].value;
        };

        ~storage[\cvs, \preamp, sym] = c[sym];

        //return symbol to collect
        sym
    });


};

