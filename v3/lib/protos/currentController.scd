//snapshotController
"buttonController".import.clone({

	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
		"longPress:%".format(k).postln;
    };

    ~onShortPress = { |k|
		nil
    };

    ~onStateChange = { |k, v|
		"stateChange: %,%".format(k,v).postln;
    }


});
