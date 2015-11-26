//targetController
"buttonController".import.clone({

    var disableSynch = false;

	~elementGroup = \arr;
	~isDeviceSendingKeyUp = false;
    ~exclusiveState = 1;
    ~inactiveState = 0;

	~isKeyInited = {
		true;
	};

	~onShortPress = { |k|
		"Select %".format(k).postln;
		1
	};

	/*
	~onDoublePress = { |k|
		"Mute/Unmute".postln;
		~current = ~previous;
		~setState.(~current, 1);
		0
	};
	*/

	~connectCV = { |cv|
		cv.addDependant(currentEnvironment);
		~onStateChange = { |k, v|
            if (v == 1) {
                disableSynch = true;
                cv.value = k;
                disableSynch=false;
            }

		};
	};

    ~update = e { |obj, what, v|
        if (what == \synch && disableSynch.not) {
            //this should be enough
		    ~setState.(v.value, 1);
        }
    };



});
