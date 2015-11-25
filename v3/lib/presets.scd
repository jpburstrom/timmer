Req.load(['storage', 'params'], { |storage, params, cleanup|
	var presets = "protos/presetCentral".import;
	var clist = List();

	storage.presets.collectInPlace { |x|
		if (x.isNil) {
			x = params.main.collect { |cv|
				cv.spec.map(1.0.rand);
			}
		};
		x
	};

	presets.presets = storage.presets;
	presets.items = params.main;
	presets.current = 0;
	presets.target = 1;


	//Target CV
	clist.add (params.meta.target.action = { |cv|
		presets.target = cv.value + 1;
	});

	//Morph CV, filter indices with macroParamSelect
	clist.add (params.meta.morph.action = { |cv|
		var selected = params.meta.macroParamSelect.rejectIndices(_ == 0);
		presets.morph(cv.value, selected);
	});




	cleanup.addFunc({
		clist.do(_.remove);
	});

	presets.postln;

	presets;

});
