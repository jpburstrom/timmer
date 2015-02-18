//buttonController
//base proto for snapshots & macros
Proto({
    ~model = (active: nil);
    ~states = [\off, \inactive, \active];
    ~actions = List();
    ~indexes = nil;
    ~longPressWaitTime = 0.5;

    //Make buttonAction responding to short & long presses
    //Args: shortPress action, longPress action, waitTime for longPress
    ~buttonActionFactory = {  |key|
        var lpr, longPress = false;
        { |val|
            if (val == 1) {
                lpr = fork {
                    ~longPressWaitTime.wait;
                    longPress = true;
                    if (~onLongPress.(key).notNil) {
                        //Set active
                        ~setState.(key, 2);
                    }
                 };
                ~onButtonDown.(key);
            } {
                lpr.stop;
                //Shortpress is activated only after
                //key is inited (from longPress or otherwise)
                if (longPress.not and: { ~isKeyInited.(key) }) {
                    ~onShortPress.(key);
                    //Set active
                    ~setState.(key, 2);
                };
                longPress = false;
            }
        }.inEnvir
    };

    //Check if a key is inited
    //Default implementation requires a long press (aka save) to init key
    //can be reimplemented for other behaviour
    ~isKeyInited = { |key|
        (~model[key] ?? 0) > 0;
    };

    ~onButtonDown = nil;

    ~onShortPress = nil;

    ~onLongPress = nil;

    //Connect model to launchpad
    ~connect = { |ktl, keys|
        ~ktl = ktl;
        ~indexes = keys;
        keys.do { |x, i|
            ktl.elementAt(\bt, x).action_(~ktlAction.inEnvir);
            ~actions.add(~buttonActionFactory.(i));
        };
        currentEnvironment;
    };

    ~ktlAction = { |e|
        ~indexes.indexOf(e.index) !? { |index|
            ~actions[index].value(e.value);
        }

    };

    ~setState = { |k, v|
        ~model[k] = v;
        //Deactivate active
        if (v == 2) {
            ~model.active !? {
                ~setState.(~model.active, 1)
            };
        };
        ~model.active = k;
        currentEnvironment.changed(\state, k, v);
    };

    ~getState = { |k|
        ~model[k] ?? 0;
    };

    ~indexAt = { |k|
        ~indexes !? { ~indexes[k] };
    }
});
