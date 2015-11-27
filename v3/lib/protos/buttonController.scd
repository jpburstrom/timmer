//buttonController
//base proto for snapshots & macros
Proto({
    ~model = ();
    ~states = [\off, \inactive, \active];
	~elementGroup = \pad;
    ~actions = List();
    ~indexes = nil;
    ~longPressWaitTime = 0.5;
	~doublePressWaitTime = 1;
	~rangePressKey = nil;
	~ignoreKeyUps = false;
	~isDeviceSendingKeyUp = true;

    //If exclusive state is set, only one button can have that state
    //Set it to the state number
    ~exclusiveState = nil;
    //if exclusive, set a state that the currently active slot is reset to
    ~inactiveState = 1;
    //current exclusive slot
    ~exclusiveKey = nil;


	~listenToSingleKey = nil;
    ~setStateFunc = \setState;
	~indexMapper;

    //Make buttonAction responding to short & long presses
    //Args: shortPress action, longPress action, waitTime for longPress
    ~buttonActionFactory = {  |key|
		var lpr, dpr, longPress = false, doublePress = false;
        { |val|
			//KEY DOWN
			var output;
			if (val == 1 && ~isDeviceSendingKeyUp) {
				//Check if other keys in group are pressed
				~ignoreKeyUps = false;
				if (~onRangePress.notNil and: { ~rangePressKey.notNil  }) {
					~listenToSingleKey = key;
				} {
					~rangePressKey = key;
				};
				lpr = fork {
					~longPressWaitTime.wait;
					longPress = ~onLongPress.notNil;
					if (~listenToSingleKey.isNil) {
						~onLongPress.(key) !? { |output|currentEnvironment[~setStateFunc].(key, output) };

					} {
						if (~listenToSingleKey == key) {
							~onRangePress.value(~rangePressKey, key, \long);
						}
					}



				};
				~onButtonDown.(key);
			}
			//KEY UP
			{
				if ((~listenToSingleKey.isNil or: { ~listenToSingleKey == key }) and: { ~ignoreKeyUps.not } ) {
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
							if (~listenToSingleKey.isNil) {
								output = ~onShortPress.(key);
							} {
								~onRangePress.value(~rangePressKey, key, \short);
								~ignoreKeyUps = true;
							}

						};
						longPress = false;
						doublePress = true;

					};
					~rangePressKey = nil;
					~listenToSingleKey = nil;

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
		keys.do(~model[_] = 0);
		//Map MKtlElement indexes to zero-based numeric indexes
        tmp = ktl.elementAt(~elementGroup).flat;
        ~indexMapper = keys.collectAs({ |k, i| tmp[k].index -> i }, IdentityDictionary);

        //TODO: probably better to do it with a single action for all keys,
        //but i'm unsure if it will break something. Leave it for now, since not broken (anymore)
		keys.do { |x, i|
            ktl.elementAt(~elementGroup, x).action_(~ktlAction.inEnvir);
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
        if (~exclusiveState.notNil) {
            //If we set active, set previous inactive
            ~doExclusiveCheck.(k, v);
        };
	    ~model[k] = v;
        ~onStateChange.(k, v);
        currentEnvironment.changed(\state, k, v);
    };

    ~getState = { |k|
        ~model[k] ?? 0;
    };

	~setAll = { |v|

		~indexes.size.do(~setState.(_, v))

	};

    ~setExclusive = { |k|
        ~setState.value(k, ~exclusiveState);
    };

    ~doExclusiveCheck = { |k, v|
        if (~exclusiveState == v) {
            ~exclusiveKey !? { |k| ~setState.(k, ~inactiveState) };
            ~exclusiveKey = k;
        } {
            //else if we for some reason are setting it back to an inactive state,
            //reset ~exclusiveKey
            if (~exclusiveKey == k) {
                ~exclusiveKey = nil;
            }
        }
    };

    ~indexAt = { |k|
        ~indexes !? { ~indexes[k] };
    };

	~free = {
		//ddwCommon quark
		currentEnvironment.releaseFromDependencies;
	}
});

/*
q.ctrls.paramSelect.actions[0].value(1);
q.ctrls.paramSelect.actions[2].value(1);
q.ctrls.paramSelect.actions[2].value(0);
q.ctrls.paramSelect.actions[0].value(0);
*/
