Req.load(#[params], { |params|
	var makeui;
    var gui = ();
    var knobCounts = IdentityDictionary();
    var rw = IdentityDictionary();
    gui.windows = IdentityDictionary();
    gui.knobs = IdentityDictionary();

	Knob.defaultMode = \vert;

    makeui = ().make {
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

	(eq: {
		makeui.grid(\eq24, 3, 8, nil, Rect(0, 0, 500, 400).center_( Window.availableBounds.center ));
		(1..24).do { |i|
			i = i.asSymbol;
			v = params.eq24[i];
			makeui.knob(i, v, \eq24, 0.01);
		}
	}
	).eq
});