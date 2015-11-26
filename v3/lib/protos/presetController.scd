//targetController
"buttonController".import.clone({

	//Set next states for long & short press
	//like a fsm
	var rangePrev;
	var longPressNextState = [1, 1, 3, 3];
	var shortPressNextState = [2, 3, 2, 3];

    //0: inactive, random
    //1: inactive, filled
    //2: active, random
    //3: active, filled
    ~exclusiveState = #[2,3];
    ~inactiveState = #[0,1];
    ~emptyState = #[0,2];


	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
        //If target is empty, move to slot
		var out = ~getState.(k) !? (longPressNextState[_]) ?? 0;
        if (~emptyState.includes(out)) {
            ~deletePreset.(k);
        } {
            ~storePreset.(k);
        };
		out;

    };

	~onShortPress = { |k|
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
            if (~exclusiveState.includes(v)) {
				cv.value = k;
			}
		};
	};

	~update = e { |obj, what, v|
		if (what == \synch and: { ~exclusiveKey != v.value } ) {
			//this should be enough
			var val = ~getState.(v.value.asInt) !? (shortPressNextState[_]) ?? 0;
			~setState.(v.value, val);
		}
	};

	~onRangePress = { |k,v|
		var range = [k,v];
		var tgt = [0, ~indexes.size - 1];
		if (range == tgt and: { range == rangePrev } ) {
			~clearPresets.value(*range);
			rangePrev = nil;
		} {
			rangePrev = [k,v];
		}
	};


});
