Req.load(nil, { |cleanup|
	var params, presetCount;

	//eqGain: 32-band eq gain
	Spec.add(\eqGain, [-6, 6, \db, 0, 0]);
	//0->empty, 1->inactive, 2->active
	Spec.add(\presetState, [0, 2, \lin, 1, 0]);
	//47 preset slots

	//All CVs should be stored in IdentityDictionaries with symbol keys
	//sequences of CVs should start at 1
	//

	params = Proto({


		var createNumberedCVs = { arg num, spec;
			//num.collectAs({ |x| (x + 1).asSymbol ->CV(spec) }, Environment).know_(true);
            num.collect { CV(spec) };
		};

		var maxPresetInterpolationTime = 10;

		var metaKeys;

		~presetCount = presetCount = 48; //current + target preset count
        ~snapshotCount = 8;

        ~randomize = { |key|
            ~getParams.(key).collect { |cv|
                if (cv.size == 0) {
                    cv.spec.map(1.0.rand);
                } {
                    { cv.spec.map(1.0.rand) } ! cv.size;
                }
            }
        };

		~pedalActions = [
			//---0: MORPH-------------
			//Morph ~current with ~target, update items
			{
				var vals;


			};
		];


		~makeCurrent = {
			~main.do { |cv, i|
				~current[i].value = cv.value;
			}
		};

		//"API" for getting saveable params
		~getParams = { |key|
            var x = switch (key)
            { \presets } { ~main }
            { \snapshots  } { ~meta_array };
            x
		};

		//"API" for getting saveable params
		~setParams = { |key, values|
            var x = switch (key)
            { \presets } { ~main }
            { \snapshots  } { ~meta_array };

			if (values.isNil) {
				values = ~randomize.(key);
			};

			x.do { |cv, i|
				cv.value = values[i]
			}
		};


		//Macro for current
		~current = createNumberedCVs.(8); //TODO: bipolar specs?
		//Macro for target
		~target = createNumberedCVs.(8); //TODO: bipolar specs?
		//these are the cooked values
		~main = createNumberedCVs.(8); //TODO: bipolar specs?


		//8 snapshot slots
		~snapshot = CV([0,7, \lin, 1, 0]);

		//Meta params are not saved with main presets
		~meta = Environment(know:true).make {
			//Morph value current->target
			~morph = CV();

			//Randomize ~main
			~random = CV([0, 0.5]);

			//holds current preset target
			~target = CV([1, presetCount-1, \lin, 1, 0]);

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



		//
		~current.do(_.addDependant(currentEnvironment));
		~target.do(_.addDependant(currentEnvironment));
		~meta.morph.addDependant(currentEnvironment);
		~meta.random.addDependant(currentEnvironment);

		~update = { |changer, what|
			if (what == \synch) {
				~meta.macroParamSelect.value.do { |x, i|
					if (x == 1) {
						var val, rand;
						r = ~meta.random.value;
						val = ~current[i].input.blend(~target[i].input, ~meta.morph.input);
						~main[i].input = val + (r - val).max(0) + r.rand2

					}
				}
			}
		};

		//TMP
		~meta.morph.connect(~slider = Slider(nil, Rect(2000, 0, 100, 400)).front);

		cleanup.addFunc({
			~slider.close;
		}.inEnvir);

	});


	// presetCount.do { |x|
	// 	params.main.current.collect {
	// 	}
	// };



	//TODO: update storage
	//reset CV values
	params

})