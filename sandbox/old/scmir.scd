/*
So this is what we should do:

Analyse the file, and create an event pattern (buffer, offset, duration)
Would it be possible to merge with other events?

Big question: Should it be possible to use several buffers in this? 
In that case:
segments: [[buffer, start, end/dur], ...]
and it would be easy to create a Event pattern, or list patterns

Look at: Pfunc, Pselect, Preject

TODO: 
merge data from several buffers
fix that buffer != path
create segment list as above, maybe w/ additional segment feature info


*/

(

~scmirFile = Proto ({
	
	~auto_segment = false;
	~singleFeatures = [[SpecCentroid], [Loudness]];
	~multiFeatures = [[MFCC, 12], [Chromagram, 12]];
	~featureDict = ();
	~features = ~singleFeatures.flop[0] ++ ~multiFeatures.flop[0];
	
	~globalNormalization = false;
	~useSavedAnalysis = true;
	
	~segmentLength = 0.1; //seconds
	~bufPaths = [];
	
	// These are "private"
	~analysis = ();
	~segments = ();
	~frames = ();
	~currentFrame = 0;
	~currentFrames = nil;
	~tree = nil;
	~list = nil;
	~walkChunks = 0;
	~walkMove = 1;
	
	~prep = {
		var analysis, frames, beatdata, segments, analFile;
		~makeFeatureDict.value;
		~bufPaths.do { |path|
			e {
	 			analFile = path.splitext[0] ++ ".scmirZ";
				if (~useSavedAnalysis && analFile.isFile) {
				 	// analFile.postln;
				 	"Found analysis file... using that one.".postln;
				 	analysis = SCMIRAudioFile.newFromZ(path);
				 	analysis.load;

			 	} {  
				 	"New file... beginning analysis".postln;
				 	analysis = SCMIRAudioFile(path, ~singleFeatures ++ ~multiFeatures);
				 	analysis.extractFeatures(true, ~globalNormalization);
				 	analysis.extractOnsets(0.05);
				 	analysis.onsetdata.postln;
				 	analysis.save;
				 	analysis.numfeatures.postln;
				 	"File Saved".postln
			 	};
			 	path = path.asSymbol;
			 	~analysis[path] = analysis;
			 	~currentFrame = 0;
				~doSegmentation.(path);
			}.fork ;
		}
	};
	
	~doSegmentation = { | path |
		if (~auto_segment) {
				 	("Performing auto-segmenting of" ++ path).postln;
				 	~segments[path] = ~analysis[path].onsetdata;
			 	} {
				 	("Performing fixed segmenting of" ++ path).postln;
				 	~segments[path] = (0, ~segmentLength..~analysis[path].duration);
			 	};
			 	~analysis[path].gatherFeaturesBySegments(~segments[path], true);
				~frames[path] = ~analysis[path].featuredata.clump(~analysis[path].numfeatures);
				~currentFrames = ~frames[path];
				~setFeatures.(nil, path);
			 	"Processing Finished... analysis ready for use.".postln;
	};
	
	~makeFeatureDict = {
		~featureDict = ();
		~singleFeatures.do({Ê|x, i| ~featureDict[x[0]] = [i, i]});
		~multiFeatures.do( { |x, i|
			var from = (~multiFeatures[..(i-1)].flop[1] ? []).sum + ~singleFeatures.size;
			var to = x[1] + from - 1;
			~featureDict[x[0]] = [from, to]
		});
		~featureDict
	};

	~setFeatures = { | feat=nil, path |
		feat ?? {Êfeat = ~singleFeatures.flop[0] ++ ~multiFeatures.flop[0] };
		~features = feat;
		~currentFrames = [];
		~features.do { |feat|
			var f = ~featureDict[feat];
			f.postln;
			~currentFrames = ~currentFrames ++ ~frames[path].flop[f[0]..f[1]];
		};
		~currentFrames = ~currentFrames.flop;

		~sort.();
		currentEnvironment
	};
	
	~sort = { | order = "feat" |
		var f;
		order.switch(
			"feat", {
				"FEAT sorting".postln;
				~tree = KDTree(~currentFrames.collect({|f, i|  f ++ i}), lastIsLabel: true);
				if (~tree.location.size > 1, 
					{Ê~list = ~tree.collect(_.label); },
					{  f = ~tree.asArray(incLabels:true);
						f = f.sort({ |x, y| x[0] <= y[0]});
						~list = f.collect(_[1])
					}
				);
			}
		);
		currentEnvironment
	};

	/*
	~move = { | dir = 0 |
		~currentFrame = ~list.at((~index.() + dir) % ~list.size);
		currentEnvironment		
	};		
	
	~selectFrame = { | x |
		x ?? { x = ~list.size.rand };
		~currentFrame = ~list.at(x);
		currentEnvironment	
	};
	
	~index = {
		~list.indexOf(~currentFrame)	
	};
	
	~currentFrameValues = {
		~currentFrames[~currentFrame]		
	};

	*/
		
	
	~currentTime = { ~segments[~currentFrame] };
	// 


});

)

// How to play
10.collect { ~scmirFile.next.index }
10.collect { ~scmirFile.walk(0.5,3).index };
10.collect { ~scmirFile.walk(0,3).index };
~scmirFile.selectFrame(10).index;

//Sort and select 10th segment 
~scmirFile.setFeatures([Loudness]).selectFrame(10).segments[~scmirFile.currentFrame];
~scmirFile.setFeatures([MFCC]).selectFrame(10).segments[~scmirFile.currentFrame];

//Play
~scmirFile.useSavedAnalysis = true
{

~scmirFile.playerArgs.durMul = 0.5


~scmirFile.playerArgs.durMul = 10
{6000000.do { ~scmirFile.walk(0, 1).play.index; (~scmirFile.playerArgs.dur *0.1.rrand(1)).wait}}.fork

{6000000.do { ~scmirFile.walk(0.6, 1).play.currentFrame.postln; (~scmirFile.playerArgs.dur * 0.5).wait}}.fork

~scmirFile.list

Patterns

Pbind
		
/*
Playerargs:
minDur
maxDur
durMul
pan / dev
width / dev
vol / dev

randomization per grain / continous? (or just per grain + separate vol/pan/width/fx synthdefs)

See Pbind help file - make scmirPlayer with default lists of:
grain position
grain duration (calc'd from pos[x+1] - pos[x] somehow?)

then these can be applied:
grain stretch
grain legato (ratio to 
grain amp (or db?)
grain pitch?


*/
