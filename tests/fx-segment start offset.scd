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

//Make segments with 5 first frames from every onset
f.gatherFeaturesBySegments(~onsets.collect { arg x; [x, x + (44.1/1024*5)] }, summarytype: 1);
~featureClump = f.featuredata.clump(f.numfeatures).collect { |x, i| x ++ i };
k = KDTree(~featureClump, lastIsLabel:true);

~treedata = NearestN.makeBufferData(k);

// Load the data to the server
~featurebuf = Buffer.sendCollection(s, ~onsets.collect({ |x, i| [] ++ x ++ ~durations[i] ++ ~featureClump[i] }).flat, f.numfeatures + 2);
~treebuf = Buffer.sendCollection(s, ~treedata.flat, ~treedata[0].size);

)
~dataThing = ~onsets.collect({ |x, i| [] ++ x ++ ~durations[i] ++ ~featureClump[i] })
(
SynthDef(\NNsegmentOffset, { |segment(0), nnbuf(0), featurebuf(0), bufnum(0), out(0), flipFactor(0), offset(0)|
	var numNN=8;
	var fadetime = 0.008;
    var snd;
	var startPos, sustain, data, newsegment;
	data = BufRd.kr(13, featurebuf, segment, 0, 1);
	//look for another segment
	newsegment = NearestN.kr(nnbuf, data[2..], Impulse.kr(0), numNN);
	segment = Select.kr(Rand() < flipFactor, [segment, Select.kr((IRand(1,numNN-1) * 3) + 2, newsegment)]);
	//get its data
	data = BufRd.kr(13, featurebuf, segment, 0, 1);
	offset = offset * data[1]; //percentage of sustain
	startPos = data[0] + offset;
	sustain = data[1] - offset;
	SendReply.kr(Impulse.kr(0), '/sustain', sustain);
	SendReply.kr(Impulse.kr(0), '/segment', segment);
	startPos = ((startPos - fadetime) * BufSampleRate.kr(bufnum)).max(0);
    snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * \bufRate.kr(1), 1, startPos);
    snd = snd * EnvGen.ar(Env([0, 1, 1, 0], [fadetime, sustain, fadetime]), doneAction:2);
    OffsetOut.ar(out, snd);
}).add;
)

//--Another thing--//
//Walk between nearest neighbours with offset
//focusing on overtones
//TODO: analyze pitch/pitch class/spectral centroid and walk between similar pitches
(
var prevSegment = 34;
//Offset goes back and forth
var offset = Pseries(0, 0.01).fold(0, 0.95).iter;
//Schedule new trigger. Always flip. Set segment to previously played segment.
OSCdef(\sus, { |msg|
	fork {
		(msg[3] - s.latency).wait;
		(offset: offset.value, instrument: \NNsegmentOffset, flipFactor: 1, segment: prevSegment, nnbuf: ~treebuf, featurebuf: ~featurebuf, bufnum: ~buf).play
	}
}.inEnvir, '/sustain');
//Set prevSegment when
OSCdef(\trackSegment, { |msg|
	prevSegment = msg[3];
}, \segment);

//Start
(instrument: \NNsegmentOffset, segment: 34, nnbuf: ~treebuf, featurebuf: ~featurebuf, bufnum: ~buf).play;


)
//Stop
OSCdef(\sus).free