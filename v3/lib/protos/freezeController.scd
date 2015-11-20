//targetController
"buttonController".import.clone({

    ~exclusiveState = 1;
    ~inactiveState = 0;


	~isKeyInited = {
		true;
	};

    ~onShortPress = {
        1
    };


    ~onStateChange = { |k, v|
        "stateChange: %,%".format(k,v).postln;
    };


});
