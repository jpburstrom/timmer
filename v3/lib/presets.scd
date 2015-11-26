Req.load(['storage', 'params'], { |storage, params, cleanup|

	var pMan = "protos/presetCentral".import;
	var sMan = "protos/presetCentral".import;

	var clist = List();

	cleanup.addFunc({
		clist.do(_.remove);
	});


	pMan.presets = storage.getPresets;
	pMan.items = params.main;
	pMan.current = 0;
	pMan.target = 1;

	//Copy values from params.target to current preset
	params.target.do { |cv, i|
		clist.add(SimpleController(cv).put(\synch, {
			pMan.presets[pMan.target][i] = cv.value;
		}));
	};

	//Target CV
    //TODO: move to presetCentral
	clist.add (params.meta.target.action = { |cv|
		pMan.target = cv.value + 1;
		params.target.do { |cv, i|
			cv.value = pMan.presets[pMan.target][i];
		}
	});
	params.meta.target.value = 1;

	//initialize current
	pMan.presets[0].do { |x, i|
		params.current[i].value = x;
	};

    //--------SNAPSHOTS----------


    sMan.presets = storage.getSnapshots;
    sMan.items = params.meta_array;
    sMan.current = 0;

	//Copy values from sMan.current to current snapshot
	params.meta_array.do { |cv, i|
		clist.add(SimpleController(cv).put(\synch, {
			sMan.presets[sMan.current][i] = cv.value;
		}));
	};
    //TODO: move to presetCentral. How cleanup?
    clist.add(params.snapshot.action = { |cv|
        var prev = sMan.presets[sMan.current];
        sMan.getPreset(cv.value.asInt);
        params.meta_array.do {|cv, i|
            cv.value = sMan.presets[sMan.current][i];
        }
    });

    params.snapshot.value = 0;

	pMan.postln;

	presets;

});
