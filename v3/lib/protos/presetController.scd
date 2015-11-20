//targetController
"buttonController".import.clone({

    //0: inactive, random
    //1: inactive, filled
    //2: active, random
    //3: active, filled
    ~exclusiveState = #[2,3];
    ~inactiveState = #[0,1];


	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
        //If target is empty, move to slot
        ~getState.(k) !? { |v|
            (1 - v.mod(2)) + (2 * v.div(2))
        } ?? 0;

    };

	~onShortPress = { |k|
        "shortPress %".format(k).postln;
		2
	};


    ~onStateChange = { |k, v|
        "stateChange: %,%".format(k,v).postln;
    };

    ~doExclusiveCheck = { |k, v|
        //We have four states, two active and two inactive
        //Deal with it
        if (~exclusiveState.includes(v)) {
            ~exclusiveKey !? { |k| ~setState.(k, ~inactiveState[~exclusiveState.indexOf(~getState.(k))]) };
            ~exclusiveKey = k;
        } {
            //else if we for some reason are setting it back to an inactive state,
            //reset ~exclusiveKey
            if (~exclusiveKey == k) {
                ~exclusiveKey = nil;
            }
        }
    };


});
