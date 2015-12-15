//targetController
"buttonController".import.clone({

    var disableSynch=false;

	~elementGroup = \bt;

	~isKeyInited = {
		true;
	};

    ~onLongPress = { |k|
		~model.keys.remove(k).do(~setState.(_,0));
		1
    };

	~onShortPress = { |k|
		1 - (~model[k] ? 0);
	};

	~onRangePress = { |k1, k2, type|
		var toggle, items = (k1..k2);
		toggle = 1 - ~model.atAll(items).product;
		if (type == \long) {
			var rest = ~model.keys - items;
			if (rest.notEmpty) {
				(rest).do(~setState.(_,0));
				items.do { |k| ~setState.(k, 1) };
			} {
				items.do { |k| ~setState.(k, toggle) };
			}
		} {
		//If any is on, turn off
			items.do { |k|
				~setState.(k,toggle);
			}

		}
	};

    ~onStateChange = { |k, v|
		//"stateChange: %,%".format(k,v).postln;
		nil
	};

	~connectCV = { |cv|
		cv.addDependant(currentEnvironment);
		~onStateChange = { |k, v|
            disableSynch = true;
            cv.value = cv.value.put(k, v);
            disableSynch=false;

		};
	};

    ~update = e { |obj, what, v|
        if (what == \synch && disableSynch.not) {
            //this should be enough
            //FIXME: feedback loop
            v.value.do { |x, i|
                ~setState.(i, x);
            };
        }
    };

});

