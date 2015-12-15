Req.load(#[params, storage], { |params, storage, cleanup|
	var makeui;
    var proto, gui = ();
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
            gui.windows[label] = parent.notNil.if(
				{ View(parent, bounds) },
				{ Window(label.asString.capitalize, bounds).front }
			).layout_(GridLayout.perform(\rows, nil ! rows ! cols))
			.background_(Color.rand(0.8, 1));

	    };
        ~knob = { |ev, label, cv, parent=\default, keystep=0.01, rowspan(1), colspan(1)|
            var ui, knob, number, rows, count = knobCounts[parent];
            rows = rw[parent]; // get rows from grid creation
            knobCounts[parent] = count + colspan; //increment ui counter
            ui = VLayout(
                knob = Knob().keystep_(keystep),
                number = NumberBox().maxDecimals_(4),
                StaticText().string_(label.asString.capitalize).align_(\topLeft).toolTip_(cv.value).mouseDownAction_({cv.value.postln; cv.value.ccopy})
                .font_(Font.default.pointSize_(13)),
            ).spacing_(0).margins_(0);
            cv.connect(knob);
            cv.connect(number);
            gui.windows[parent].layout.addSpanning(ui, count div: rows, count % rows, rowspan, colspan);
            ui
        };
		~button = { |ev, states, action, parent, rowspan(1), colspan(1)|
			var ui, knob, number, rows, count = knobCounts[parent];
			rows = rw[parent];
			knobCounts[parent] = count + colspan;
			if (states.isKindOf(String)) {
				states = [[states, Color.black, Color.white]];
			};
			ui = Button().states_(states).action_(action);
			gui.windows[parent].layout.addSpanning(ui, count div: rows, count % rows, rowspan, colspan);
		};
        ~label = { |ev, label, parent, rowspan(1), colspan(1)|
            var count = knobCounts[parent];
            var rows = rw[parent];
            knobCounts[parent] = count + colspan;
            gui.windows[parent].layout.addSpanning(
                StaticText().string_(label.asString.capitalize).align_(\top),
                count div:rows, count % rows, rowspan, colspan
            );
        };
		~spacer = { |ev, parent, rowspan(1), colspan(1)|
            var count = knobCounts[parent];
            var rows = rw[parent];
            knobCounts[parent] = count + colspan;
            gui.windows[parent].layout.addSpanning(
				View(),
                count div:rows, count % rows, rowspan, colspan
            );
        };
    };

	proto = Proto({
		~eq = { |parent|
			var ui = makeui.grid(\eq24, 2, 12, parent, Rect(1600, 0, 500, 400));
			var labels = params.eqFreqs.cpsname;
			makeui.label("EQ", \eq24, 1, 12);
			params.eqFreqs.size.do { |i|
				var v = params.eq24[i];
				makeui.knob(labels[i], v, \eq24, 0.01);
			};

			//Store to storage.zarchive
			makeui.button("Store", {
				storage.storeToGroup(\eq, 0);
			}, \eq24, 1, 2);

			//Store to storage.zarchive
			makeui.button("Revert", {
				storage.loadToGroup(\eq, 0);
			}, \eq24, 1, 2);

			//Save to separate file
			makeui.button("Save as", {
				storage.saveSingle(\eq);
			}, \eq24, 1, 2);

			//Load separate file
			makeui.button("Open", {
				//Load and store to preset 0
				storage.loadSingle(\eq, nil, 0);
			}, \eq24, 1, 2);


		};
        #[main, current, target].do { |key|
            currentEnvironment[key] = { |parent|
                var ui = makeui.grid(key, 1, 8, parent, Rect(1600, 0, 500, 100));
                makeui.label(key.asString.capitalize, key, 1, 8);
                [
                    "Mshift Depth",
                    "Mshift Speed",
                    "Mshift Mix",
                    "Tremol Depth",
                    "Tremol Speed",
                    "Tremol Mix",
                    "Reson Amp",
                    "Reverb Mix"
                ].do { |k, i|
                    var v = params[key][i];
                    makeui.knob(k, v, key, 0.01);
                };
            };
		};
		~meta = { |parent|
			var ui;
			var labels = [\morph, \random, \target, \interpolationTime];
			ui = makeui.grid(\meta, 1, 8, parent, Rect(1600, 0, 500, 100));
			labels.do { |k|
				var v = params.meta[k];
				makeui.knob(k.asString[..12], v, \meta, 0.01);
			};

            ["Amp=>DLFO", "Amp=>ALFO", "Amp=>Detune", "Amp=>Reverb"].do { arg k, i;
				var v = params.meta.featureMap[i];
				makeui.knob(k, v, \meta, 0.01);
			}
		};
		~utils = { |parent|
			//Save to separate file
			var ui = makeui.grid(\utils, 1, 8, parent, Rect(1600, 0, 500, 100));
			makeui.button("Save as", {
				storage.saveDialog;
			}, \utils);

			//Load separate file
			makeui.button("Open", {
				//Load and store to preset 0
				storage.loadDialog;
			},  \utils);
			makeui.spacer(\utils, 1, 6);
		};
		~makeWindow = {
			var p = Window.new("Hello", Rect(1600, 0, 800, 400)).front.layout_(VLayout());
			~eq.value(p.layout);
			~main.value(p.layout);
			~target.value(p.layout);
			~current.value(p.layout);
			~meta.value(p.layout);
			~utils.value(p.layout);
			gui.windows[\mainWindow] = p;
			p

		}

	});

	proto.makeWindow;
	cleanup.addFunc { gui.windows.do(_.close) };

	proto;

});
