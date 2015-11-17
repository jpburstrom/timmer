//macroController
//short press: toggle
//multiple active

q.f.getProto(\buttonController).clone({

    ~buttonActionFactory = {  |key|
        var lpr, longPress = false;
        { |val|
            if (val == 1 and: { ~isKeyInited.(key) }) {
                ~toggleState.(key);
            }
        }
    };

    ~onStateChange = { |k, v|
        q.macros.run(k, v==2);
    };

    //Make macros update on macro updates
    q.macros.addDependant(currentEnvironment);

    ~update = e { |obj, what, k, v|
        if (what == \put) {
            if (v.notNil) {
                ~setState.(k, 1);
            } {
                ~setState.(k, 0);
            }
        }
    };



});
