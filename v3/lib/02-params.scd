
//eqGain: 32-band eq gain
Spec.add(\eqGain, [-6, 6, \db, 0, 0]);
//0->empty, 1->inactive, 2->active
Spec.add(\presetState, [0, 2, \lin, 1, 0]);
//47 preset slots



//All CVs should be stored in IdentityDictionaries with symbol keys
//sequences of CVs should start at 1
//
q.make {
	~storage.presets = (); //TODO: get from archive

	~storage.params = ().make {

		var createNumberedCVs = { arg num, spec;
			num.collectAs({ |x| (x + 1).asSymbol ->CV(spec) }, IdentityDictionary).know_(true);
		};
		var presetCount = 47;
		var maxPresetInterpolationTime = 10;

		//main presets
		//blendable
		~main = IdentityDictionary(know:true).make {

			//Macro for current
			~current = createNumberedCVs.(8); //TODO: bipolar specs?


			//Macro for target
			~target = createNumberedCVs.(8); //TODO: bipolar specs?

		};

		//8 snapshot slots
		~snapshot = CV([0,7, \lin, 1, 1]);

		//Meta params are not saved with main presets
		~meta = IdentityDictionary(know:true).make {
			//holds current preset target
			~target = CV([1, presetCount, \lin, 1, 1]);
			//Morph value current->target
			~morph = CV();
			//preset interpolation time
			~presetInterpolationTime = CV([0, maxPresetInterpolationTime]);

			//Selects which macro params are updated/morphed (top row on LP)
			~macroParamSelect = CV(\binary, 0!8); //Array of 8 values

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


		//eq is sold separately
		~eq24 = 24.collectAs({ |x| (x + 1).asSymbol ->CV(\eqGain) }, IdentityDictionary).know_(true);
	};



};
