//targetController
"buttonController".import.clone({

	//Set next states for long & short press
	//like a fsm
	var rangePrev;
	var longPressNextState = [1, 1, 3, 3];
	var shortPressNextState = [2, 3, 2, 3];
	var clearPresetNextState = [0, 0, 2, 2];

    //0: inactive, random
    //1: inactive, filled
    //2: active, random
    //3: active, filled
    ~exclusiveState = #[2,3];
    ~inactiveState = #[0,1];
    ~emptyState = #[0,2];

	~cvOffset = 0;
	~storageKey = nil;

	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
        //If target is empty, move to slot
		var out = ~getState.(k) !? (longPressNextState[_]) ?? 0;
		~storePreset.(k);
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

	//Connect to CV with a possible offset
	~connectCV = { |cv, offset(0)|
		~cvOffset = offset;
		cv.addDependant(currentEnvironment);

		//Force update from CV
		~exclusiveKey.debug("Exclusive key");
		~exclusiveKey = nil;
		cv.changed(\synch, cv);

		~onStateChange = { |k, v|
			"stateChange: %,%".format(k,v).postln;
			if (~exclusiveState.includes(v)) {
				cv.value = k + ~cvOffset;
			}
		};

	};

	~update = e { |obj, what, kgrp|
		var k = (kgrp.value - ~cvOffset).asInt;
		//Get update from CV, but only if key has changed
		if (what == \synch and: { ~exclusiveKey != k } ) {
			//this should be enough
			var val = ~getState.(k) !? (shortPressNextState[_]) ?? 0;
			~setState.(k, val);
		} {
			if (what == \activeKeys and: { ~storageKey == kgrp }) {
				~updateFromStorage.(obj, kgrp);
			}
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

	~clearPresets = { |from, to|
		(from..to).do { |x|
			~deletePreset.(x);
		}
	};

	//update from storage, with a possible offset
	~connectStorage = { |storage, key, offset(0)|
		//Update state to "filled"  for each index, if storage's toStore flag is set
		var toStore = storage.getActiveKeys(key);
		storage.addDependant(currentEnvironment);
		~storageKey = key;
		~updateFromStorage = { |obj, group, force(false)|
			if (group == key) {
				~indexes.size.do { |k|
					var tmp = ~getState.(k).mod(2);
					var new = toStore.includes(k + offset).asInt;
					if (new != tmp or: { force }) {
						~setState.(k, new);
					}
				};
			}
		};
		~storePreset = { arg x; "attempting to store".postln; storage.storeToGroup(key, x+offset);  };
		~deletePreset = { arg x; storage.removeFromGroup(key, x+offset);  };

		~updateFromStorage.value(storage, key, true);

	};

	~storePreset = {
		"connect to storage to store".warn;
	};

	~deletePreset = {
		"connect to storage to delete".warn;
	}



});
