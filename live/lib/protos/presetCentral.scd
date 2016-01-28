Proto({
	//Dictionary with CVs or similar

	//Raw params, constantly updating current and target presets
    ~currentParams = nil;
	~targetParams = nil;

	//The output params, collected when saving preset
	~cookedParams = nil;

	//Dictionary with preset values
    ~presets = ();
	//Index to static presets
    ~currentIndex = 0;
	//index to static presets
    ~targetIndex = 1;

	~controllers = List();

	//Set groups of params
	//If morph is needed, all three should be set
	//otherwise just one is needed
	~setParams = { |cooked, current, target|
		var c = ~controllers;
		~free.value;
		if (current.isNil) {
			current = cooked;
		};
		if (target.isNil) {
			~morph = ~morphInactive;
		} {
			~morph = ~morphActive;
			//Constantly update from target params to target preset
			target.do { |cv, i|
				//Do a first update from presets
				~presets[~targetIndex][i] !? (cv.value = _) ;
				//then hook up to sync from cv
				c.add(cv.action_({
					~presets[~targetIndex][i] = cv.value;
				}.inEnvir));
			};
		};

		current.do { |cv, i|
			//Do a first update from presets
			~presets[~currentIndex][i] !? (cv.value = _);

			//then hook up to sync from cv

			c.add(cv.action_({
				~presets[~currentIndex][i] = cv.value;
			}.inEnvir));

		};

		~cookedParams = cooked;
		~currentParams = current;
		~targetParams = target;
	};

	//Set current index with a value or CV
	~setCurrentIndex = { |val|
		~setIndex.value(\currentIndex, \currentParams, val);
	};

	//Set target index with a value or CV
	~setTargetIndex = { |val|
		~setIndex.value(\targetIndex, \targetParams, val);
	};

	~setIndex = { |indexKey, paramsKey, val|
		var c = ~controllers;
		if (val.isKindOf(CV)) {
			c.add (val.action_({ |cv|
				currentEnvironment[indexKey] = cv.value.asInt;
				currentEnvironment[paramsKey].do { |param, i|
					param.value = ~presets[currentEnvironment[indexKey]][i];
				}
			}.inEnvir));

		} {
			currentEnvironment[indexKey] = val;
		}

	};

    ~setPresetContainer = { arg c;
        ~presets = c;
    };


    ~addPreset = { arg index;
        ~presets[index] = ~cookedParams.collect(_.value);
    };

    ~removePreset = { arg index;
        ~presets[index] = nil;
    };


    ~setCurrent = { |key|
        ~currentIndex = key;
    };

    ~setTarget = { |key|
        ~targetIndex = key;
    };

    //Get preset, update cooked by default
    //Optionally pass keys to select subset of items
    ~getPreset = { arg index, keys,update(true);
        var idx = index ?? ~current;
        var vals = ~presets[idx];
        if (keys.notNil) { vals = vals.select { |v,k| keys.includes(k) } };
        ~currentIndex = idx; //Should we set current?
        vals.do { |v, k| ~cookedParams[k] !? (_.value = v); };
    };

	~morphInactive = {
		"Morph needs target params".warn;
		nil
	};

    //Morph ~currentIndex with ~targetIndex, update items by default
    //Optionally pass keys to select subset of items
    ~morphActive = { |amt, keys, update(true)|
        var vals;
        if (keys.isNil) {
            vals = ~presets[~currentIndex].blend(~presets[~targetIndex], amt);
        } {
            vals = ~presets[~currentIndex].select({ |v,k| keys.includes(k) })
            .blend(~presets[~targetIndex], amt, false);
        };
        //if update == false, only return values
        if (update) {
			vals.keys.do { |k| ~cookedParams[k] !? (_.value = vals[k].value); };
        };
        vals;
    };

	~free = {
		//ddwCommon quark
		~controllers.do(_.remove);
		currentEnvironment.releaseFromDependencies;
	}
});
