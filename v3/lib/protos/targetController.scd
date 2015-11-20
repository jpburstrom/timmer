//targetController
"buttonController".import.clone({


	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
		"longPress:%".format(k).postln;

    };

	~onShortPress = { |k|
        "shortPress %".format(k).postln;
		0.rrand(4)

	};
	~onRangePress = { |k1, k2, type|
		"rangePress: %,%,%".format(k1,k2, type).postln;
		nil
	};

    ~onStateChange = { |k, v|
		"stateChange: %,%".format(k,v).postln;
    }


});
