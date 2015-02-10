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
                StaticText().string_(label.asString.capitalize).align_(\topLeft).toolTip_(cv.value).mouseDownAction_({cv.value.postln; cv.value.ccopy}),
            ).spacing_(0).margins_(0);
            cv.connect(knob);
            cv.connect(number);
            gui.windows[parent].layout.add(ui, count div: rows, count % rows);
            ui
        }

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
    Toolbar.replace(\Phase, {
        q.makeui.grid('Phase', 5, 8, nil, Rect(0, 0, 500, 400).center_( Window.availableBounds.center ));
        q.settings.pitches.clump(5).flop.flatten.do { |x|

            var cv = q.cvs.phase[x.asSymbol];
            cv !? {
                q.makeui.knob(x.asSymbol, cv, 'Phase', 0.0001);
            }
        };
    });
}
