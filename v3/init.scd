s.waitForBoot {

	//bug: can't load synths after loading devices,
	//creates new param instances?
	//Something with reload:true
	Req.load(['lib/storage', 'lib/params', 'lib/presets', 'lib/devices', 'lib/gui'],
		{ arg storage, params, presets, devices, gui;
			q.devices = devices;
			q.params = params;
			q.storage = storage;
			q.presets = presets;
	}, reload:true);

};