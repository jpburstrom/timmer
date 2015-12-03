Req.load(#[params, synth], { |params, synth, cleanup|
	var srcID, pedalNum, actions, pedalFunc;
	var ss, ssLeds, ssLedWait, ssNum, makeAction;

	//TODO: store previous value and compare
	var softset = { |cv, value, within=0.1|
		var curr;
		curr = cv.input;
		value = value / 127;
		if (absdif(curr, value) <= within) {
			cv.input = value;
		}
	};

	SoftStep.connect;


	//--------Expression pedal--------------

	srcID = MIDIIn.findPort("SSCOM", "Port 1").uid;
	pedalNum = 86; //cc for pedal;
	actions = nil ! 8;
	pedalFunc = MIDIFunc.cc({ arg val;

		actions[params.meta.selectedPedalAction.value].value(127 - val);


	}, pedalNum, 0, srcID);

	actions[0] = { |val|
		softset.(params.meta.morph, val);
	};

	actions[1] = { |val|
		softset.(params.meta.random, val);

	};

	actions[2] = { |val|
		softset.(params.meta.target, val);
	};

	//------Freeze pedals---------------

	ssNum = 10;
	ssLedWait = nil ! ssNum;
	ssLeds = SoftStepLedGroup();

	makeAction = { |x|
		{ |val|

			if (val == 1) {
				var w = synth.triggerFreezeSynth(x) * 0.5;
				ssLedWait[x].stop;
				ssLeds.set(x, 1, 1);
				ssLedWait[x] = fork {
					w.wait;
					ssLeds.set(x, 1, 0);
					w.wait;
					ssLeds.set(x, 0, 0);
				};
			};
		}

	};

	ssLeds.setAll(0);

	ss = 10.collect { |x|
		SSTrigResponder(makeAction.value(x), x)
	};

	cleanup.addFunc {
		pedalFunc.free;
		ss.do(_.free);
	};

});
