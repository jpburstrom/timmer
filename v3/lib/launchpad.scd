Req.load([\params, \storage], { |params, storage, cleanup|

	var lpIn, lpOut, ctrls, views;


    //launchPad key mapping
    var keys = (
		current: [0],
		target: (1..47),
		freezeScale: (48..55),
		metaPreset: (56..63),
		paramSelect: (0..7),
		pedalActions: (0..7),

    );
	//Colors for state toggling
	//Short press
	//Long press
	//Pass an array to blink between two colors
    var colors = (
        //TODO: set colors
        current: #[off, [off, red]],
		target: #[lAmber, [off, lGreen], amber, [off, green]],
		freezeScale: #[lRed, red],
		metaPreset: #[lAmber, lGreen, amber, green],

        paramSelect: #[off, lRed],
		pedalActions: #[off, amber, green],

	);
	cleanup.addFunc {
		ctrls.do(_.free);
	};

	ctrls = ();
	views = ();

	lpIn = MKtl('launchpad', "*launchpad-mini", true);
	if (lpIn.device.notNil) {

		lpOut = LaunchpadOut(lpIn).reset;
		//Autoflash
		lpOut.midiOut.control(0, 0, 40);

        //Pairs of key => controllerProtoNames
       #[
			current, currentController,
			target, presetController,
			freezeScale, freezeController,
			metaPreset, presetController,
            paramSelect, paramSelectController,
			pedalActions, pedalActionController
		].pairsDo { |k,v|
			//Connect controller to device IN
			ctrls[k] = "protos/%".format(v).import.connect(lpIn, keys[k]);
			//Connect view to device OUT
            //All have same view
			views[k] = "protos/buttonView".import.connect(ctrls[k], lpOut);
			//set colors
			views[k].colors = colors[k];
		};

		ctrls[\current].setState(0, 1);
		ctrls[\current].onStateChange = {
			storage.storePreset(0);
			params.makeCurrent;
		};


		ctrls[\freezeScale].connectCV(params.meta.freezeScale);
		ctrls[\freezeScale].setAll(0);

        ctrls[\paramSelect].connectCV(params.meta.macroParamSelect);
        ctrls[\pedalActions].connectCV(params.meta.selectedPedalAction);

		//Connect to CV with an offset
		//controller outputs values from 0-47, but this CV needs 1-48
		ctrls[\target].updateFromStorage(storage.getActiveKeys(\presets), 1);
		ctrls[\target].connectCV(params.meta.target, 1);
		ctrls[\target].storePreset = { arg x; storage.storePreset(x+1);  }; //TODO

		ctrls[\metaPreset].updateFromStorage(storage.getActiveKeys(\snapshots));
		ctrls[\metaPreset].connectCV(params.snapshot);
		ctrls[\metaPreset].storePreset = (storage.storeSnapshot(_)); //TODO


	};

	ctrls


});

