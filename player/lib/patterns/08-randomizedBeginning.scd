var pl = Plazy({
	//assuming q.player is playing track 08
	var motif = q.player.data.onset[..17].flop[1];

	var quant = 0.125; //quantize
	var weights = motif.round(quant).asBag.asWeights;
	var rand = quant * [-0.5, 0.5];

	var patBaseDur = Pbind(
		\instrument, \testDrum,
		\dur, Pwrand(weights[0], weights[1], inf) + Pwhite(*rand)
	);
	var patStutter = Prout({ |ev|
		//Duration threshold. If dur <= 0.05, count it as a repetition
		var repetitionThreshold = 0.05;
		//Make a list of booleans. Is this a repetition?
		var repList = motif.differentiate.abs.collect(_ <= repetitionThreshold);
		//Number of non-repeated values
		var uniqueCount = repList.reject(_.value);

		//Repetition choices, starting at a single event, then event + rep, then event + 2x rep...
		var choices = (1..10);
		//Assuming max number of repetitions is 10
		var weights = 0 ! choices.size;

		//Go through every boolean in repList
		var repCount = 0;
		repList.do { |isRep|
			if (isRep) {
				//For every repetition, increment repCount
				repCount = repCount + 1;
			} {
				//For every non-repetition, add repCount to repProb and reset repCount
				weights[repCount] = weights[repCount] + 1;
				repCount = 0;
			}

		};

		//Normalized probability of 0->10 repeats
		weights = weights.normalizeSum;

		loop {
			//According to the plot, only durations between ~0.5 and ~1 is repeated.
			if (ev.dur > 0.45 and: { ev.dur < 1.05 }) {
				//Repeat each event x times

				choices.wchoose(weights).yield;
			} {
				1.yield;
			}

		}

	});

	//## Grace notes ##
	//Not in the plot: some notes have grace notes.
	//Listening to the track, we find that there are 4 of them,
	//giving a 4/18 = 22% probability of a grace note.
	//But it also seems like only longer notes have them, so lets account for that

	var patGrace = value {
		//Find the middle
		var middle = [motif.minItem, motif.maxItem].mean;

		//Let prob be probability of a note longer than mean
		var prob = 0.22 /  (motif.reject(_ < middle).size / motif.size);
		Pbind(

			\amp, Pfunc { |ev|

				var out = 0.8.rrand(1); //some random amp

				//If this test passes, output an array, creating two notes
				//Assuming Pbrown has an even distribution, which it hasn't
				if (ev.dur > middle and: { prob.coin }) {
					out = [0.1.rrand(0.2), out];

					if (0.5.coin) { out = out.reverse }

				};
				out
			},
			\strum, Pwhite(0.08, 0.15)
		)
	};

	//## Legato ##
	//Some notes are longer than others. They seem to often come in pairs.
	//Two times during the short track we go into a 'branch' of long->short note pairs
	//Here we translate that into a probability of 2/size of doing it
	//and a 90% chance of repeating the pair twice (even though it's 100% in the track)

	var patLegato = value {
		Pbind(
			\sustain, p { |ev|
				var prob = 2/motif.size;
				var sustainShort=0.5;
				var sustainLong=1;
				loop {
					//If we have legato, we go into this branch
					if (prob.coin) {
						//90% chance of repeating twice
						[1,2].wchoose([0.1, 0.9]).do {
							sustainLong.yield;
							sustainShort.yield;
						}
					};
					//Always yield short after a group of longs
					sustainShort.yield;
				}
			},
			//Adjust grace notes
			\sustain, Pfunc { |ev|
				if (ev.dur.isArray) {
					ev.sustain = [0.1, ev.sustain];
				};
				ev.sustain
			}
		)
	};

	Pchain(
		patLegato,
		patGrace,
		Psmartstutter(patStutter, patBaseDur)
	);

});

Pdef(\t08randomizedBeginning, pl)


