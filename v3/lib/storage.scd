Req.load(['params'], { |params, cleanup|
	//TODO: load from disk
	//Kolla på hur gamla grejer har gjort detta
	var storage = Proto({

		var path = "../data/storage.archive".resolveRelative;

		~things = (); //saveable?

		~storeSnapshot = { |k|
			k.debug("storing snapshot");
			params.getSnapshotParams.do { arg x, i;
				~snapshots[k][i] = x.value;
			}
		};

		~storePreset = { |k|
			k.debug("storing preset");
			params.getPresetParams.do { arg x, i;
				~presets[k][i] = x.value;
			};
			~save.value;
		};


		~save = {
			"FIXME: implement storage storing".warn;
			~things.writeArchive(path);
		};

		~load = {
			~things = Object.readArchive(path);
		};


	});
	storage.presets ?? { storage.presets = nil ! params.presetCount };
	storage.presetsToStore = storage.presets.rejectIndices(_ == nil).asSet;

	storage.snapshots ?? { storage.snapshots = nil ! 8 };
	storage.snapshotsToStore = storage.snapshots.rejectIndices(_ == nil).asSet;

	storage;
});