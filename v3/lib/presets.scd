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

	//Copy values from params.target to current preset
	params.target.do { |cv, i|
		clist.add(SimpleController(cv).put(\synch, {
			presets.presets[presets.target][i] = cv.value;
		}));
	};

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

	//Copy values from snapshots.current to current snapshot
	params.meta_array.do { |cv, i|
		clist.add(SimpleController(cv).put(\synch, {
			snapshots.presets[snapshots.current][i] = cv.value;
		}));
	};
    //TODO: move to presetCentral. How cleanup?
    clist.add(params.snapshot.action = { |cv|
        var prev = snapshots.presets[snapshots.current];
        snapshots.getPreset(cv.value.asInt);
        params.meta_array.do {|cv, i|
            cv.value = snapshots.presets[snapshots.current][i];
        }
    });

    params.snapshot.value = 0;

	presets.postln;

	presets;

});
