//##Trying something here
(
"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("08");

//First 18 onsets have a kind of main rhythmic motif
q.player.setIterator(Pseries(0, 1, 18));
q.player.setPtn(Pbind(
	\dur, Pkey(\dur).trace
));
q.player.play;

//... where we want to look at the durations:
~motif = q.player.data.onset[..17].flop[1];
~motif.plot.plotMode_(\plines);
)

//So now we want to transfer this rhytmic idea to a random stream, which somehow
//still has the same vibe as the recording.

//We create a SynthDef to test with.
(
SynthDef(\testDrum, { |freq, amp =1, sustain=0.1|
	var snd = BPF.ar(Decay.ar(Impulse.ar(0), 0.1) * 10, 60, 0.01) * EnvGen.ar(Env.perc(0, sustain), doneAction:2);
	Out.ar(0, (snd * 6 * amp ).softclip.dup);

}).add;
)


//### First try. Random values from min to max ###
(
Pbindef(\test_08_Pwhite,
	\instrument, \testDrum,
	\legato, 0.1,
	\dur, Pwhite(~motif.minItem, ~motif.maxItem),
).play;
)
Plprand

Pdef(\test_08_Pwhite).stop;

//### Second try. Brownian motion between min and max ###
(
var maxChange = ~motif.differentiate.maxItem;
Pbindef(\test_08_Pbrown,
	\instrument, \testDrum,
	\amp, 1,
	\legato, 0.1,
	\dur, Pbrown(~motif.minItem, ~motif.maxItem, maxChange)
).play
)

Pdef(\test_08_Pbrown).stop;

//### Third try. Quantize duration, calculate prob for every value, and add some noise from -0.5q to 0.5q ###
(
var q = 0.125; //quantize
var weights = ~motif.round(q).asBag.asWeights;
//
var rand = q * [-0.5, 0.5];

Pbindef(\test_08_Pwrand,
	\instrument, \testDrum,
	\legato, 0.1,
	\dur, Pwrand(weights[0], weights[1], inf) + Pwhite(*rand);
).play
)

Pdef(\test_08_Pwrand).stop;

//Ok, that sounds somewhat musical, even though it's not there yet.
//When looking at the plot, a thing to notice is that some durations seem to repeat.
//So let's try to mimic this.
(
Pdef(\test_08_Pwrand_stutter, Psmartstutter(Prout({ |ev|
	//Duration threshold. If dur <= 0.05, count it as a repetition
	var repetitionThreshold = 0.05;
	//Make a list of booleans. Is this a repetition?
	var repList = ~motif.differentiate.abs.collect(_ <= repetitionThreshold);
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

}), Pdef(\test_08_Pwrand))
).play;
)


//## Grace notes ##
//Not in the plot: some notes have grace notes.
//Listening to the track, we find that there are 4 of them,
//giving a 4/18 = 22% probability of a grace note.
//But it also seems like only longer notes have them, so lets account for that
(
//Find the middle
var middle = [~motif.minItem, ~motif.maxItem].mean;

//Let prob be probability of a note longer than mean
var prob = ~motif.reject(_ < middle).size / ~motif.size;

//And if note is longer than mean, what should the probability be
//to make the total probability of a grace note be 0.22?
prob = 0.22/prob; //~0.66
//After listening, this seems to be a bit high, but maybe that's more about the sound of the
//handclaps

Pdef(\test_08_Pwrand_stutter_grace, Pchain(
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
	),
	Pdef(\test_08_Pwrand_stutter)
)).play;
)

//## Legato ##
//Some notes are longer than others. They seem to often come in pairs.
//Two times during the short track we go into a 'branch' of long->short note pairs
//Here we translate that into a probability of 2/size of doing it
//and a 90% chance of repeating the pair twice (even though it's 100% in the track)
(
Pdef(\test_08_Pwrand_stutter_grace_legato, Pchain(
	Pbind(
		\sustain, p { |ev|
			var prob = 2/~motif.size;
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
	),
	Pdef(\test_08_Pwrand_stutter_grace)
).trace).play;
)

Pdef(\test_08_Pwrand_stutter_grace_legato).gui

