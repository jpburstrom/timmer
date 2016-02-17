(
var c, data;

~buf = Buffer.read(s, "../../render/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;
~path = "/Users/johannes/projects/timmer/render/01-Preparerad flageolett 2 ___-44100.wav";

//TODO: Find good, useful features
~features = [[MFCC, 10]];

f = SCMIRAudioFile(~path, ~features);
f.extractFeatures();
f.gatherFeaturesBySegments(~onsets);

//--Cluster it--
c = 30;
data = f.featuredata.clump(f.numfeatures);
data = data.collect { |r, i|
	r ++ (~durations.maxItem / ~durations[i])
};
k = KMeans(c);
data.do(k.add(_));
k.update;
~clusters = c.collect(k.assignments.indicesOfEqual(_));

~clusters.collect(_.size).select(_==1).size;
)

(
//Playback.
//Play linearly, but occasionally swap one segment with another in the same cluster
Pbindef(\asd,
	\flip, Pfunc { var flip = 0.1.coin; flip },
	\counter, Pseries(0, 1, ~onsets.size),
	\index, Pif(Pkey(\flip), Pfunc { |ev|
		~clusters[k.assignments[ev.counter]].reject(_==ev.counter).choose ?? ev.counter;
	}, Pkey(\counter)),
	\dur, Pfunc { |ev| ev.startPos = ~onsets[ev.index]; ~onsets[ev.index + 1] !? (_ - ev.startPos) ?? 10; },
	\instrument, \varTest,
	\legato, 1
).play;
)

Pdef(\asd).stop

~clusters
Proutine
(
//Occasionally jump (permanently) to another segment in the same cluster
Pbindef(\asd,
	\flip, Pfunc { var flip = 0.1.coin; flip },
	\index, p { |ev|
		var i = 0;
		var clusters = ~clusters.deepCopy;
		var ass = k.assignments;
		loop {
			i.postln;
			if (ev.flip) {
				i = clusters[ass[i]].reject(_ == i).choose.postln ?? i;
			};
			~clusters[ass[i]].remove(i);
			ev = i.yield;
			i = i + 1;

		}
	},
	\dur, Pfunc { |ev| ev.startPos = ~onsets[ev.index]; ~onsets[ev.index + 1] !? (_ - ev.startPos) ?? 10; },
	\instrument, \varTest,
	\legato, 1
).play;
)

Pdef(\asd).clear
