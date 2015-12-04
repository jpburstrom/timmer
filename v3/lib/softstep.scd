Req.load(#[params, synth], { |params, synth, cleanup|
	var srcID, pedalNum, actions, pedalFunc;
	var ss, ssLeds, ssLedWait, ssNum, makeAction;

	var softset, softsetFact = {
		var prev;
		{ |cv, value, within=0.02|
			var curr;
			curr = cv.input;
			value = value / 127;
			if (absdif(curr, value) <= within or: { cv.value == prev }) {
				cv.input = value;
				prev = cv.value;
			}
		}
	};

	SoftStep.connect;


	//--------Expression pedal--------------

	srcID = MIDIIn.findPort("SSCOM", "Port 1").uid;
	pedalNum = 86; //cc for pedal;
	actions = nil ! 8;
	softset = softsetFact ! 8;
	pedalFunc = MIDIFunc.cc({ arg val;

		actions[params.meta.selectedPedalAction.value].value(127 - val);


	}, pedalNum, 0, srcID);

	//Set pedal actions where params.meta.selectedPedalAction is...
	//(See params.scd)
	//0: Morph

	actions[0] = { |val|
		softset[0].(params.meta.morph, val);
	};

	//1: Parameter randomization
	actions[1] = { |val|
		softset[1].(params.meta.random, val);

	};

	//2: Preset select (Target)
	actions[2] = { |val|
		softset[2].(params.meta.target, val);
	};

	//3: Interpolation time
	actions[3] = { |val|
		softset[3].(params.meta.interpolationTime, val);
	};

	//4-7: featureMap, mapping audio features to parameters
	4.do { |i|
		actions[i+4] = { |val|
			softset[i+4].(params.meta.featureMap[i], val);
		};
	};

	//------Freeze pedals---------------

	ssNum = 10;
	ssLedWait = nil ! ssNum;
	ssLeds = SoftStepLedGroup();

	makeAction = { |x|
		{ |val|

			if (val == 1) {
				var w = synth.triggerFreezeSynth(x) * 0.5; //Returns synth duration
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
