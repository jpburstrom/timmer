Req.load(['lib/storage', 'lib/params', 'lib/presets', 'lib/devices', 'lib/gui'],
    { arg storage, params, presets, devices, gui;
   q.devices = devices;
        q.params = params;
        q.storage = storage;
}, reload:true);


