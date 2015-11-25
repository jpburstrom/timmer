Req.load(['storage'], { |storage|
	var params;

	//eqGain: 32-band eq gain
	Spec.add(\eqGain, [-6, 6, \db, 0, 0]);
	//0->empty, 1->inactive, 2->active
	Spec.add(\presetState, [0, 2, \lin, 1, 0]);
	//47 preset slots

	//All CVs should be stored in IdentityDictionaries with symbol keys
	//sequences of CVs should start at 1
	//

	params = ().make {


		var createNumberedCVs = { arg num, spec;
			//num.collectAs({ |x| (x + 1).asSymbol ->CV(spec) }, Environment).know_(true);
            num.collect { CV(spec) };
		};

		var presetCount = storage.presets.size - 1; //target preset count
		var maxPresetInterpolationTime = 10;

        ~randomize = { |ev, key|
            ev[key].collect { |cv|
                if (cv.size == 0) {
                    cv.spec.map(1.0.rand);
                } {
                    { cv.spec.map(1.0.rand) } ! cv.size;
                }
            }
        };

		//Macro for current
		~current = createNumberedCVs.(8); //TODO: bipolar specs?
		//Macro for target
		~target = createNumberedCVs.(8); //TODO: bipolar specs?
		//these are the cooked values
		~main = createNumberedCVs.(8); //TODO: bipolar specs?

		~makeCurrent = {
			~main.do { |cv, i|
				~current[i].value = cv.value;
			}
		}.inEnvir;

		//8 snapshot slots
		~snapshot = CV([0,7, \lin, 1, 1]);

		//Meta params are not saved with main presets
		~meta = Environment(know:true).make {
			//holds current preset target
			~target = CV([0, presetCount - 1, \lin, 1, 0]);
			//Morph value current->target
			~morph = CV();
			//preset interpolation time
			~presetInterpolationTime = CV([0, maxPresetInterpolationTime]);

			//Selects which macro params are updated/morphed (top row on LP)
            ~macroParamSelect = CV([0,1,\lin,1,1], 1!8); //Array of 8 values

			//Selects current pedal action (LP scene buttons)
			~selectedPedalAction = CV([0,7,\lin,1,0]);

			//Pedal actions

			//Feature map amount (1-4)
			//Controlled with foot pedal
			~featureMap = createNumberedCVs.(4);

			//Enable feature map (1-4)
			~featureMapEnable = createNumberedCVs.(4, \binary);

			//Select current scale for freeze pedals
			~freezeScale = CV([0,7,\lin,1,0]);

		};

        //preset likes 1-dim arrays
        ~meta_array = ~meta.keys.asArray.sort.collect({ |k|
            ~meta[k];
        }).flat;


		//eq is sold separately
        ~eq24 = 24.collect({CV(\eqGain) });
	};


	// presetCount.do { |x|
	// 	params.main.current.collect {
	// 	}
	// };



	//TODO: update storage
	//reset CV values
	params

})