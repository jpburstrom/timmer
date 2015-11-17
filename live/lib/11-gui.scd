Knob.defaultMode = \vert;
q.make {
    var gui = ();
    var knobCounts = IdentityDictionary();
    var rw = IdentityDictionary();
    gui.windows = IdentityDictionary();
    gui.knobs = IdentityDictionary();

    ~makeui = ().make {
        ~grid = { |ev, label=\default, rows=4, cols=8, parent, bounds|
            var cls = Window;
            label.postln;
            rw[label] = cols;
            knobCounts[label] = 0;
            bounds = bounds ?? { Rect(0,0,400,400).center_( Window.availableBounds.center ) };
            gui.windows[label] !? { gui.windows[label].close };
            parent !? { cls = View };
            gui.windows[label] = cls.perform(\new, label.asString.capitalize).front
            .layout_(GridLayout.perform(\rows, nil ! rows ! cols))
            .bounds_(bounds)
            .background_(Color.rand(0.8, 1))
            ;
        };
        ~knob = { |ev, label, cv, parent=\default, keystep=0.01|
            var ui, knob, number, rows, count = knobCounts[parent];
            rows = rw[parent]; // get rows from grid creation
            knobCounts[parent] = count + 1; //increment ui counter
            ui = VLayout(
                knob = Knob().keystep_(keystep),
                number = NumberBox().maxDecimals_(4),
                StaticText().string_(label.asString.capitalize).align_(\topLeft).toolTip_(cv.value).mouseDownAction_({cv.value.postln; cv.value.ccopy})
                .font_(Font.default.pointSize_(13)),
            ).spacing_(0).margins_(0);
            cv.connect(knob);
            cv.connect(number);
            gui.windows[parent].layout.add(ui, count div: rows, count % rows);
            ui
        };
        ~label = { |ev, label, parent|
            var count = knobCounts[parent];
            var rows = rw[parent];
            knobCounts[parent] = count + 1;
            gui.windows[parent].layout.add(
                StaticText().string_(label.asString.capitalize).align_(\top),
                count div:rows, count % rows
            );
        };
    };

    ~ui = gui;
};

defer {
    /*
    Toolbar.replace(\delayAdj, {
    q.makeui.grid('Delay adjustment', 4, 12, nil, Rect(0, 0, 800, 400).center_( Window.availableBounds.center ));
    q.settings.pitches.do { |x|

    var cv = q.cvs.delayAdjustment[x.asSymbol];
    cv !? {
    q.makeui.knob(x.asSymbol, cv, 'Delay adjustment');
    }
    };
    });
    */

    var pitches = q.f.getPitchesForUI;

    [
        Phase: \phase,
        Preamp: \preamp,
        Delay: \delay,
        Amp: \amp

    ].pairsDo { |label, key|

        Toolbar.replace(label, {
            q.makeui.grid(label, 3, 8, nil, Rect(0, 0, 500, 300).center_( Window.availableBounds.center ));
            pitches.do { |x|

                var cv = q.storage[\cvs, key, x.asSymbol];
                cv !? {
                    q.makeui.knob(x.asSymbol, cv, label, 0.0001);
                }
            };
        });
    };

    Toolbar.replace(\Global, {
        q.makeui.grid(\Global, 1, 8, nil, Rect(0, 0, 500, 100).center_( Window.availableBounds.center ));
        q.settings.paramLists.global.do { |k|
            q.makeui.knob(k, q.storage[\cvs, \global, k], \Global, 0.01);
        }
    });

    Toolbar.replace(\Mod, {

        q.makeui.grid(\Mod, 3, 9, nil, Rect(0, 0, 700, 300).center_( Window.availableBounds.center ));
        q.settings.paramLists.modTop.do { |tup, i|
            var from, to, label;
            #from, to = tup;
            if (i%8 == 0) {
                q.makeui.label(from, \Mod);
            };
            q.makeui.knob(to, q.storage[\cvs, \modulation, from, to], \Mod, 0.01);
        };
        q.makeui.label(\lfoxws, \Mod);

        q.settings.paramLists.modLFO.do { |tup|
            var from, to;
            #from, to = tup;
            q.makeui.knob(to, q.storage[\cvs, \modulation, from, to], \Mod, 0.01);
        };

    });

}
