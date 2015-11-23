(
q.make {
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

	~dev = ();
    ~views = ();
    ~ctrls = ();

	~dev.lpIn = MKtl('launchpad', "*launchpad-mini", true);
	if (~dev.lpIn.device.notNil) {
		~dev.lpOut = LaunchpadOut(~dev.lpIn).reset;
		//Autoflash
		~dev.lpOut.midiOut.control(0, 0, 40);

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
			~ctrls[k] = "protos/%".format(v).import.connect(~dev.lpIn, keys[k]);
			//Connect view to device OUT
            //All have same view
			~views[k] = "protos/buttonView".import.connect(~ctrls[k], ~dev.lpOut);
			//set colors
			~views[k].colors = colors[k];
		};

        //TODO: Connect controllers to CVs


	};

}
);

/*
q.dev.lpIn.elementAt(\pad, 0).action
q.ctrls.current.actions[0].value(1);q.ctrls.current.actions[0].value(0)
q.dev.lpIn.elementAt(\pad, \1).index
q.ctrls.current.indexes.indexOf(q.dev.elementAt(\pad, 0))
q.dev.lpIn.elementAt(\pad, 0).index
*/

