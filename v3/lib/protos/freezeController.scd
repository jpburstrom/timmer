//targetController
"buttonController".import.clone({

    ~exclusiveState = 1;
    ~inactiveState = 0;


	~isKeyInited = {
		true;
	};

    ~onShortPress = {
        1
    };

   ~connectCV = { |cv|
		cv.addDependant(currentEnvironment);
		~onStateChange = { |k, v|
			if (~exclusiveState == v) {
				cv.value = k;
			}
		};
	};

	~update = e { |obj, what, v|
		if (what == \synch and: { ~exclusiveKey != v.value } ) {
			//this should be enough
			//FIXME: feedback loop
			~setState.(v.value, ~exclusiveState);
		}
	};

});
