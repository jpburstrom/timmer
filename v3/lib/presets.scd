p = Req.load(['params', 'storage'], { |params, storage, cleanup|

	var presets = "protos/presetCentral".import;
	var snapshots = "protos/presetCentral".import;

	var clist = List();

	cleanup.addFunc({
		presets.free; snapshots.free;
	});



	presets.setPresetContainer(storage.getPresets);
	presets.setParams(params.main, params.current, params.target);
	presets.setCurrentIndex(0);
	presets.setTargetIndex(params.meta.target);

    //--------SNAPSHOTS----------

	snapshots.setPresetContainer(storage.getSnapshots);
	snapshots.setParams(params.meta_array);
	snapshots.setCurrentIndex(params.snapshot);

	[presets, params];

});


