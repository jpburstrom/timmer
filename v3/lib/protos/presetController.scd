//targetController
"buttonController".import.clone({

	//Set next states for long & short press
	//like a fsm
	var longPressNextState = [1, 0, 3, 2];
	var shortPressNextState = [2, 3, 2, 3];

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
		~getState.(k) !? (longPressNextState[_]) ?? 0;

    };

	~onShortPress = { |k|
        "shortPress %".format(k).postln;
		k.postln;
		~getState.(k) !? (shortPressNextState[_]) ?? 0;
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

	~connectCV = { |cv|
		cv.addDependant(currentEnvironment);
		~onStateChange = { |k, v|
			cv.value = k;
		};
	};

	~update = e { |obj, what, v|
		[what, v, ~onShortPress].postln;
		if (what == \synch) {
			//this should be enough
			//FIXME: feedback loop
			var val = ~getState.(v.value) !? (shortPressNextState[_]) ?? 0;

			//HACK: change state without ~onStateChange, to avoid feedback
			~model[v.value] = val;
			~model.postln;
			currentEnvironment.changed(\state, v.value, val);
		}
	};

});
