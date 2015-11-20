//snapshotController
"buttonController".import.clone({

	~isKeyInited = {
		true;
	};

    ~onShortPress = { |k|
       1
    };

    ~onStateChange = { |k, v|
		"stateChange: %,%".format(k,v).postln;
    }


});
