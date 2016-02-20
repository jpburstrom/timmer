(
var c, data, dur;

~buf = Buffer.read(s, "../player/songs/01-Preparerad flageolett 2 ___-44100.wav".resolveRelative);
~onsets = TabFileReader.read("../player/data/01/onset.txt".resolveRelative).flop[0].collect(_.asFloat);
~durations = ~onsets.differentiate[1..] ++ 30;


//TODO: Find good, useful features
)
(
~features = [Chromagram];
f = SCMIRAudioFile(~buf.path, ~features, 1);
f.extractFeatures(false);
f.gatherFeaturesBySegments(~onsets.collect { arg x ; [x + 0.1, x + 0.1 + (44.1/1024*5)] }, summarytype: 1);
)

x = f.featuredata.clump(12).collect(_.maxIndex)
f
//Make segments with 5 first frames from every onset
~featureClump = f.featuredata.clump(f.numfeatures).collect { |x, i| x ++ i };

)


k = KDTree(~featureClump, lastIsLabel:true);

~treedata = NearestN.makeBufferData(k);

// Load the data to the server
~featurebuf = Buffer.sendCollection(s, ~onsets.collect({ |x, i| [] ++ x ++ ~durations[i] ++ ~featureClump[i] }).flat, f.numfeatures + 2);
~treebuf = Buffer.sendCollection(s, ~treedata.flat, ~treedata[0].size);

Pdef(\test).stop
(
Pdef(\test,
	Ppar([
		Pbind(
			\instrument, \bufSegment,
			\legato, 1,
			\bufnum, ~buf,
			\counter, Pseries(),
			\startPos, Pseq(~onsets),
			\dur, Pseq(~durations),
		),
		Pbind(
			\counter, Pseries(),
			\legato, 1,
			\note, Pseq(x),
			\dur, Pseq(~durations),
			\amp, 0.05
		),
	])
).play
)
	