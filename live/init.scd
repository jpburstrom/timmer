s.options.sampleRate=96000;
s.options.hardwareBufferSize = 128;
s.options.memSize = 65536*8;
s.waitForBoot {

	Req.load(['lib/storage', 'lib/params', 'lib/presets', 'lib/devices', 'lib/gui', 'lib/synth'],
		{ arg storage, params, presets, devices, gui, synth;
			q.devices = devices;
			q.params = params;
			q.storage = storage;
			q.presets = presets;
			q.syn = synth;

			params.current.do(_.changed(\synch));


	}, reload:true);

};


