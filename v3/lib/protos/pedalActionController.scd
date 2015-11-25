//targetController
"buttonController".import.clone({

	~elementGroup = \arr;
	~isDeviceSendingKeyUp = false;

	~previous = nil;
	~current = nil;

	~isKeyInited = {
		true;
	};

	~onShortPress = { |k|
		"Select %".format(k).postln;
		~current !? {
			~setState.(~current,0);
		};
		~previous = ~current;
		~current = k;
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


	~onStateChange = { |k, v|
		"stateChange: %,%".format(k,v).postln;
    }


});
