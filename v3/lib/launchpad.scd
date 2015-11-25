Req.load([\params, \storage], { |params, storage, cleanup|

	var lpIn, lpOut, ctrls, views, clist=List();


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

	cleanup.addFunc {
		clist.do(_.remove);
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

		ctrls[\target].connectCV(params.meta.target);
		//target has presets 1-47
		keys.target.size.do { |k|
			ctrls[\target].setState(k, storage.presetsToStore.includes(k + 1).asInt);
		};
		clist.add(
			SimpleController(ctrls[\target]).put(\state, { |obj, what, k, v|
				if ([0,2].includes(v)) {
					storage.presetsToStore.remove(k);
				} {
					storage.presetsToStore.add(k);
				}
			});
		);

		ctrls[\metaPreset].connectCV(params.snapshot);
        ctrls[\metaPreset].storePreset = { |k|
            "storing preset %".format(k).postln;
            params.meta_array.do { arg x, i;
                storage.snapshots[k][i] = x.value;
            }
        };
        ctrls[\metaPreset].deletePreset = { "delete".postln };
		//snapshots 0-7
		8.do { |k|
			ctrls[\metaPreset].setState(k, storage.snapshotsToStore.includes(k).asInt);
		};
		clist.add(
			SimpleController(ctrls[\metaPreset]).put(\state, { |obj, what, k, v|
				if ([0,2].includes(v)) {
					storage.snapshotsToStore.remove(k);
				} {
					"adding".debug(k);
					storage.snapshotsToStore.add(k);
				}
			});
		);

		ctrls[\freezeScale].connectCV(params.meta.freezeScale);
		8.do(ctrls[\freezeScale].setState(_, 0));

		ctrls[\current].onStateChange = params[\makeCurrent]; //a function to move main -> current


		//-----upper row---------

		8.do(ctrls[\paramSelect].setState(_,1));

        ctrls[\paramSelect].connectCV(params.meta.macroParamSelect);
        ctrls[\pedalActions].connectCV(params.meta.selectedPedalAction);
		ctrls[\pedalActions].setState(0, 1)


	};

	ctrls


});

