Req.load(['params'], { |params, cleanup|
	//TODO: load from disk
	//Kolla på hur gamla grejer har gjort detta
	var storage = Proto({

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
		};


		~save = {
		};

		~load = {
		};


	});
	storage.presets ?? { storage.presets = nil ! params.presetCount };
	storage.presetsToStore = storage.presets.rejectIndices(_ == nil).asSet;

	storage.snapshots ?? { storage.snapshots = nil ! 8 };
	storage.snapshotsToStore = storage.snapshots.rejectIndices(_ == nil).asSet;

	storage;
});