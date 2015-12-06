Req.load(nil, { |cleanup|
	var params, presetCount;

	//eqGain: 32-band eq gain
	Spec.add(\eqGain, [-24, 12, \db, 0, 0]);
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

		var metaKeys;

        var paramUpdater;

		//Array of frequencies for EQ
		~eqFreqs = (36..59).midicps;

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
		//if set is true, get the params that should be set
		~getParams = { |key, set(false)|
            var x;
			x = switch (key)
			{ \eq } { ~eq24 }
			{ \presets } { if (set) { ~target } { ~main } }
            { \snapshots  } { ~meta_array ++ ~current };
            x
		};

		//"API" for getting saveable params
		~setParams = { |key, values|
			var x = ~getParams.(key, true);

			[key, values].debug("setting params");

			if (values.isNil) {
				values = ~randomize.(key);
			};

			x.do { |cv, i|
				if (values[i].isKindOf(cv.value.class).not) {
					"params.setParams: Value with index % of key % couldn't be set".format(i, key).warn;
				} {
					cv.value = values[i]
				}
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
			~random = CV([0, 0.5, 8]);

			//holds current preset target
			~target = CV([1, presetCount-1, \lin, 1, 0]);

			//Interpolation time
			//Used to
			~interpolationTime = CV();

			//Selects which macro params are updated/morphed (top row on LP)
            ~macroParamSelect = CV([0,1,\lin,1,1], 1!8); //Array of 8 values

			//Selects current pedal action (LP scene buttons)
			~selectedPedalAction = CV([0,7,\lin,1,0]);

			//Pedal actions

			//Feature map amount (1-4)
			//Controlled with foot pedal
			~featureMap = createNumberedCVs.(4);

			//Enable feature map (1-4) (currently unused)
			~featureMapEnable = createNumberedCVs.(4, \binary);

			//Select current scale for freeze pedals
			~freezeScale = CV([0,7,\lin,1,0]);

		};



		//preset likes 1-dimensional arrays
		//order is arbitrary, but needs to be consistent for preset loading
		//so to be able to add/change name of elements, we hardcode the order
		~meta_array = #[ featureMap, featureMapEnable, freezeScale, macroParamSelect,
			morph, interpolationTime, random, selectedPedalAction, target ].collect({ |k|
            ~meta[k];
        }).flat;

		//eq is sold separately
        ~eq24 = ~eqFreqs.size.collect({CV(\eqGain) });



		//
		~current.do(_.addDependant(currentEnvironment));
		~target.do(_.addDependant(currentEnvironment));
		~meta.morph.addDependant(currentEnvironment);
		//XXX Is it a good idea to let random update all values?
        ~meta.random.addDependant(currentEnvironment);

        paramUpdater = { |i|
            var val, r;
            r = ~meta.random.value;
            val = ~current[i].input.blend(~target[i].input, ~meta.morph.input);
            ~main[i].input = val + (r - val).max(0) + r.rand2
        }.inEnvir;

		~update = { |changer, what|
			if (what == \synch) {
                //If param from ~current or ~target has changed, only update that column
                //Otherwise (random or morph) update all in ~meta.macroParamSelect
                ~current.indexOf(changer) !? { |i|
                    paramUpdater.value(i);
                } ?? {
                    ~target.indexOf(changer) !? { |i|
                        paramUpdater.value(i);
                    } ?? {
                        ~meta.macroParamSelect.value.do { |x, i|
                            if (x == 1) {
                                paramUpdater.value(i);
                            }
                        }
                    }
                }
			}
		};

	});


	// presetCount.do { |x|
	// 	params.main.current.collect {
	// 	}
	// };



	//TODO: update storage
	//reset CV values
	q.params = params;
	params

})