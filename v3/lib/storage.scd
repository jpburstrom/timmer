Req.load(nil, {
	//TODO: load from disk
	var storage = ();
	storage.presets ?? { storage.presets = nil ! 48 };
	storage.presetsToStore = storage.presets.rejectIndices(_ == nil).asSet;

	storage.snapshots ?? { storage.snapshots = nil ! 8 };
	storage.snapshotsToStore = storage.snapshots.rejectIndices(_ == nil).asSet;

	storage;
});