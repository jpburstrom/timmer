(
var c, data, dur;

~buf = Buffer.read(s, "../../render/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;
~path = "/Users/johannes/projects/timmer/render/01-Preparerad flageolett 2 ___-44100.wav";

//TODO: Find good, useful features
~features = [Loudness, [MFCC, 10]];
f = SCMIRAudioFile(~path, ~features);
f.extractFeatures();

//Make segments with 5 frames from every onset
f.gatherFeaturesBySegments(~onsets.collect { arg x; [x, x + (44.1/1024*5)] });
~featureClump = f.featuredata.clump(f.numfeatures).collect { |x, i| x ++ i };
k = KDTree(~featureClump, lastIsLabel:true);


Pdef(\featureOrder2, Pbind(
	\bufnum, ~buf,
	\index, Pseq(~featureClump.order({ |x,y| x.median > y.median })),
	\dur, Pfunc { |ev| ev.startPos = ~onsets[ev.index]; ~onsets[ev.index + 1] !? (_ - ev.startPos) ?? 10; },
	\attackStartPos, Pkey(\startPos),
	\instrument, \varTest,
	\legato, 1
).trace).play

)

m = f.similarityMatrix
m.plot(2)
SCMIRStructuralSummary
k.find(~featureClump[0]).nearestToNode[0].label

(
//Playback.
//Play linearly, but occasionally swap one segment with another in the same cluster
Pbindef(\knn1,
	\flip, Pfunc { var flip = 0.9.coin; flip },
	\counter, Pseries(0, 1, ~onsets.size),
	\index, Pif(Pkey(\flip), Pfunc { |ev|
		k.find(~featureClump[ev.counter]).nearestToNode[0].label
	}, Pkey(\counter)).trace,
	\attackSegment, Pkey(\index),
	\dur, Pfunc { |ev| ev.startPos = ~onsets[ev.index]; ~onsets[ev.index + 1] !? (_ - ev.startPos) ?? 10; },
	\instrument, \varTest,
	\legato, 1
).play;
)

(
Pdef(\featureOrder2, Pbind(
	\bufnum, ~buf,
	\index, Pseq(~featureClump.order({ |x,y| x.median < y.median })),
	\dur, Pfunc { |ev| ev.startPos = ~onsets[ev.index]; ~onsets[ev.index + 1] !? (_ - ev.startPos) ?? 10; },
	\attackStartPos, Pkey(\startPos),
	\instrument, \varTest,
	\legato, 1
).trace).play
)
Pbindef(\featureOrder2).stop
