Req.load(['storage', 'params'], { |storage, params, cleanup|

	var presets = "protos/presetCentral".import;
	var snapshots = "protos/presetCentral".import;
	var clist = List();

	cleanup.addFunc({
		clist.do(_.remove);
	});

    //get lots of random presets
	storage.presets.collectInPlace { |x|
		if (x.isNil) {
            x = params.randomize(\main);
		};
		x
	};

	presets.presets = storage.presets;
	presets.items = params.main;
	presets.current = 0;
	presets.target = 1;

	//Target CV
    //TODO: move to presetCentral
	clist.add (params.meta.target.action = { |cv|
		presets.target = cv.value + 1;
		params.target.do { |cv, i|
			cv.value = presets.presets[presets.target][i];
		}
	});
	params.meta.target.value = 1;

	//initialize current
	presets.presets[0].do { |x, i|
		params.current[i].value = x;
	};

	//Morph CV, filter indices with macroParamSelect
	clist.add (params.meta.morph.action = { |cv|
		var selected = params.meta.macroParamSelect.value.rejectIndices(_ == 0);
		presets.morph(cv.value, selected);
	});

    //--------SNAPSHOTS----------

    //get lots of random presets
	storage.snapshots.collectInPlace { |x|
		if (x.isNil) {
            x = params.randomize(\meta_array);
		};
		x
	};

    snapshots.presets = storage.snapshots;
    storage.snapshots.postln;
    snapshots.items = params.meta_array;
    snapshots.current = 0;

    //TODO: move to presetCentral. How cleanup?
    clist.add(params.snapshot.action = { |cv|
        var prev = snapshots.presets[snapshots.current];
        prev.debug("prev");
        snapshots.getPreset(cv.value.asInt);
        params.meta_array.do {|cv, i|
            //TODO: store previous on preset change
            //This doesn't work
            //prev[i] = cv.value;
            cv.value = snapshots.presets[snapshots.current][i];
        }
    });

    params.snapshot.value = 0;

	presets.postln;

	presets;

});
