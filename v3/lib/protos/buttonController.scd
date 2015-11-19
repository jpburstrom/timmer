//buttonController
//base proto for snapshots & macros
Proto({
    ~model = (active: nil);
    ~states = [\off, \inactive, \active];
    ~actions = List();
    ~indexes = nil;
    ~longPressWaitTime = 0.5;
	~doublePressWaitTime = 1;
	~rangePressKey = nil;
	~listenToSingleKey = nil;
    ~setStateFunc = \setState;
	~indexMapper;

    //Make buttonAction responding to short & long presses
    //Args: shortPress action, longPress action, waitTime for longPress
    ~buttonActionFactory = {  |key|
		var lpr, dpr, longPress = false, doublePress = false, rangePress = false;
        { |val|
			//KEY DOWN
			var output;
            if (val == 1) {
				//Check if other keys in group are pressed
				~ignoreKeyUps = false;
				if (~onRangePress.notNil and: { ~rangePressKey.notNil  }) {
					~listenToSingleKey = key;
					//lpr.stop;
					rangePress = true;

				} {
					~rangePressKey = key;
				};
				lpr = fork {
					~longPressWaitTime.wait;
					longPress = true;
					if (rangePress.not) {
						output = ~onLongPress.(key);

					} {
						"rangePress".postln;
						~onRangePress.value(~rangePressKey, key, \long);
						rangePress = false;

					}



				};
				~onButtonDown.(key);
			}
			//KEY UP
			{
				if (~listenToSingleKey.isNil or: { ~listenToSingleKey == key } ) {
					~listenToSingleKey = nil;
					lpr.stop;
					dpr.stop;

					dpr = fork {
						~doublePressWaitTime.wait;
						doublePress = false;
					};
					if (doublePress and: { ~onDoublePress.(key).notNil }) {
						doublePress = false;
						output = ~onDoublePress.(key);
					} {
						//Shortpress is activated only after
						//key is inited (from longPress or otherwise)
						if (longPress.not and: { ~isKeyInited.(key) }) {
							if (rangePress.not) {
								output = ~onShortPress.(key);
							} {
								~onRangePress.value(~rangePressKey, key, \short);
								rangePress = false;
								~ignoreKeyUps = true;
							}

						};
						longPress = false;
						doublePress = true;

					};
					~rangePressKey = nil;

				} {
					lpr.stop;
					dpr.stop;

				}
			};
			//Set state, if output is not nil
			//output.postln;
			output !? { currentEnvironment[~setStateFunc].(key, output) };
		}.inEnvir
    };

    //Check if a key is inited
    //Default implementation requires a long press (aka save) to init key
    //can be reimplemented for other behaviour
    ~isKeyInited = { |key|
        (~model[key] ?? 0) > 0;
    };

    ~onButtonDown = nil;

	//Default action: toggle on short press
	~onShortPress = { |k|
		1 - ~getState.value(k);
	};

    ~onLongPress = nil;

	~onDoublePress = nil;

    //Connect model to launchpad
    ~connect = { |ktl, keys|
		var tmp;
        ~ktl = ktl;
        ~indexes = keys;
		//Map MKtlElement indexes to ~index indexes
		~indexMapper = q.dev.lpIn.elementAt(\pad).flat.collectAs({ |k,v| k.index->keys.indexOf(v) }, IdentityDictionary)
		//keep only indexes from ~indexes
		.select( { |v,k|
			keys.includes(k.asInt);
		});
		keys.do { |x, i|
            ktl.elementAt(\pad, x).action_(~ktlAction.inEnvir);
			~actions.add(~buttonActionFactory.(i));
        };
        currentEnvironment;
    };

    ~ktlAction = { |e|
		~indexMapper[e.index] !? { |index|
		~actions[index].value(e.value);
        }

    };

    ~setState = { |k, v|
        ~model[k] = v;
        ~onStateChange.(k, v);
        currentEnvironment.changed(\state, k, v);
    };

    ~getState = { |k|
        ~model[k] ?? 0;
    };

    ~indexAt = { |k|
        ~indexes !? { ~indexes[k] };
    }

});
