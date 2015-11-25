Req.load([\params], { |params, cleanup|

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
        current: [\off, #[fRed, red]],
		target: #[lAmber, lGreen, amber, green],
		freezeScale: #[lRed, red],
		metaPreset: #[lAmber, lGreen, amber, green],

        paramSelect: [\off, \lRed],
		pedalActions: #[off, amber, green],

	);


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

		"connecting target".postln;
		ctrls[\target].debug("target");
		q.targetCV = params.meta.target.debug("cv");
		ctrls[\target].connectCV(params.meta.target);
		ctrls[\metaPreset].connectCV(params.snapshot);
		ctrls[\freezeScale].connectCV(params.meta.freezeScale);


	};

	ctrls


});


/*
q.params.snapshot.value = 8.rand
q.params.meta.target.value = 47.rand
q.target.target.model[0]
q.target.target.getState(q.params.meta.target.value.asInt)
q.target.target.setState(0, 3)
q.target.target.setState(1, 2)
3 !? ([2,3,2,3][_]) ?? 0
