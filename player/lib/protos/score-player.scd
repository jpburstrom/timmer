var songBasePath = "../../songs".resolveRelative;
var dataBasePath = "../../data".resolveRelative;
var synthDefsPath = "../01-synthdefs.scd".resolveRelative;



Proto({
    var count = -1;

    ~soundFile = nil;
    ~songPath = nil;
    ~dataPath = nil;
    ~channels = 2;
    ~bufferPool = "buffer-pool".import;
    ~numBufs = 8; //Number of buffers used in buffer pool
    ~data = ();

    ~readyForPlay = false;

    //Setting this sets random seed on player start
    ~randSeed = nil;


    //dictionary of per-label functions
    ~actions = ();
    //an ordered list of marker labels
    ~actionLabels = #[onset];
    //Lowest common denominator, the tick
    ~tickLabel = \onset;



    //Iterator
    ~iteratorPattern = PatternProxy(Pseries());
    //Stream it
    ~iteratorStream = ~iteratorPattern.asStream;
    //Set nextPos to temporarily override iterator
    ~nextPos = nil;
    //Keep track of previous segment
    ~prevPos = -1;
    //~nextEvent, ~prevEvent;


    //eventstreamplayer placeholder
    ~streamPlayer = nil;
    ~isRendering = false;

    //Event things
    ~protoEvent = (instrument:\diskSegment, db: 0, group: { ~t.mainGroup.nodeID }.inEnvir, outbus: { ~t.mainOut.index }.inEnvir );

    //Dictionary of key => pattern to modify ~nextEvent with
	~modPtn = EventPatternProxy(Pbind());



    //Set iterator pattern
    ~setIterator = { |ptn|
        ~iteratorPattern.source_(ptn);
    };

	~setPtn = { |ptn|
		~modPtn.source_(ptn);
	};


    //TODO: move this to separate file?
	//TODO: Find good, useful features
	~features = [Loudness, [MFCC, 10]];
    //Length (in frames) of feature segments
    ~featureSegmentLength = 5;
    //Size of k-nearest neighbour array (== k in k-nearest?)
    ~knnSize = 6;

    //Extract features, generate KDTree and
    ~extractFeatures = {

        var f, file;

        file = (~dataPath +/+ "features.scmirZ");
        f = SCMIRAudioFile.asClass.new(~songPath, ~features);
        if (File.exists(file).not) {
            f.extractFeatures();
            f.save(file);
        } {
            f.load(file);

        };

		//Make segments with n frames from every tick
        if (~data[~tickLabel].notNil) {
            f.gatherFeaturesBySegments(~data[~tickLabel].collect { arg x; [x[0], x[0] + (44.1/1024*5)] });
			~data.featureClump = f.featuredata.clump(f.numfeatures).collect { |x, i| x ++ i };

            //For now, we keep this. For later: create a tree only when we need to.
			~data.kdTree = KDTree(~data.featureClump, lastIsLabel:true);

            ~data.knn = ~readDataFile.("%-knn-%".format(~tickLabel, ~knnSize), { |writeFunc|
                //Poor man's brute-force nearest neighbour search
                //If this doesn't work maybe `NearestN` ugen could be something
                //We're forking this process to avoid beachballs (don't know if it works)
                {
                    var step = 0.03;
                    var size = q.player.data.featureClump.size;
                    var time = Main.elapsedTime;
                    var neighbours = q.player.data.featureClump.collect({ |point, index|
                        var radius = 0.16;
                        var points = [];
                        //Go on until we have ~knnSize points.
                        //Default is 6, which means we have 5 points plus current.
                        while { points.size < (~knnSize) } {
                            points = q.player.data.kdTree.radiusSearch(point, radius);
                            radius = radius + step;
                        };
                        points = points.collect { |x| [(x.location - point).sum{|x| x * x}, x.label] };
                        //We include the current point in the array
                        points = points.sort({ |x,y| x[0] < y[0] })[0..5].flop[1];
                        if  ((index % 50) == 0) {
                            "generating neighbours... % of %".format(index, size).postln;
                            (Main.elapsedTime - time + 0.05).wait;
                            time = Main.elapsedTime;
                        };
                        points;

                    });
                    "Done generating neighbours".postln;
                    writeFunc.(neighbours);

                    ~data.knn = neighbours;

                }.inEnvir.fork;

                //Returning nil, since we need to set ~data.knn after running fork
                nil
            });
        };
    };

    //Get a neighbour index from the `~data.knn` array,
    //where 0 is the same index.
    ~getknn = { |index, distance=0|
        ~data.knn[index] !? { |x| x[distance.clip(0, ~knnSize - 1)] }
    };

    //Read data file from filename (relative to ~datapath).
    //If file doesn't exist, run func with full path as argument.
    //Return object/result of func
    ~readDataFile = { |relpath, missingFunc|
        var writeFunc;
        relpath = ~dataPath +/+ relpath ++ ".archive";
        writeFunc = { |obj| obj.writeArchive(relpath) };
        if (File.exists(relpath)) {
            Object.readArchive(relpath);
        } {
            //Ok, this is too smart: pass a write function to the callback
            missingFunc.(writeFunc);
        };
    };

    //Write data file
    //Pass an object to write, a relative path, and a function to call when file exists.
    //The function is passed a writeFunc as only argument, which can be used to write the file
    //from the callback
    ~writeDataFile = { |obj, relpath, existsFunc|
        var writeFunc;
        relpath = ~dataPath +/+ relpath ++ ".archive";
        writeFunc = { obj.writeArchive(relpath) };
        if (File.exists(relpath)) {
            //Since file exists, we maybe want to confirm or something before
            //writing, so we pass a writeFunc to the callback
            existsFunc.value(writeFunc);
        } {
            //If file doesn't exist, just go ahead and write
            writeFunc.();
        }
    };

    //Load data from song label
    //song is folder in dataBasePath,
    //or first match of dash-terminated prefix of song file basename (eg 01 => 01-song-name-year-month-day-time.wav")
    ~loadData = { |song|
        ~song = song;
        ~dataPath = dataBasePath +/+ song;
        ~songPath = (songBasePath +/+ song ++ "*.wav").pathMatch.last;
        SoundFile.use(~songPath, { |sf|

            var isNumeric = { |x|
                "^(?=.)([+-]?([0-9]*)(\\.([0-9]+))?)$".matchRegexp(x);
            };

            ~soundFile = sf;
            ~actionLabels.do { |k|
                var path = ~dataPath +/+ k ++ ".txt";
                if (File.exists(path)) {
                    var tmp, durations, data = TabFileReader.read(path);
                    //If we only have one time value per row, we calculate durations
                    if (data[0].size == 1 or: { data[0][1].notNil and: { isNumeric.(data[0][1]).not } }) {
                        var times = data.flop[0].collect(_.asFloat);
                        tmp = times ++ sf.duration;
                        durations = tmp.differentiate[1..];
                        ~data[k] = [times, durations].flop;

                    } {
                        //Otherwise we have another format, and then we need to convert every numeric
                        //value to float.
                        data.collectInPlace { |line|
                            //SV outputs regions as time, value, duration, label
                            //and notes as time, pitch, duration, level, label
                            //so we assume duration comes as third value in array
                            //and re-order, so duration always comes second
                            if (line.size > 2) {
                                line.swap(2,1);
                            };
                            line.collect({ |x|
                                if (isNumeric.(x)) {
                                    x.asFloat;
                                } {
                                    x
                                }
                            });
                        };
                        ~data[k] = data;

                    }

                } {
                    ~data[k] = [[],[]];
                    "loadData: File % doesn't exist".format(path).warn;
                };

                //Add action dictionary for label, if not exists
                if (~actions[k].isNil) {
                    ~actions[k] = ();
                };

            };

            ~prepareScore.value;
        }.inEnvir);



    };

    //Prepare score
    //Normally run from ~loadData
    ~prepareScore = {
        var otherKeys, idxs = (), cur=();
        var coll = ~data[~tickLabel];
        var defaultInst = ~defaultInst;
        otherKeys = ~actionLabels.copy;
        otherKeys.remove(~tickLabel);
        ~data.lookup = otherKeys.collectAs(_->List(), Event);
        ~data.score = coll.collect { |times, i|
            cur[~tickLabel] = i;
            cur.copy.make({ ~startPos =  times[0]; ~dur = times[1]; ~legato = 1;});
        };

        otherKeys.do { |k|
            var other = ~data[k];

            //Quantize other keys to ~tickLabel
            other.do { |x, j|
                var inTime = x[0];
                var outTime = x[0] + x[1];
                var in = ~data[~tickLabel].detectIndex { |times|
                    (inTime <= times[0]) and:  {( (j+1) == other.size ) or: { times[0] < outTime }}
                };
                var out = ~data[~tickLabel].detectIndex({ |times|
                    times[0] > outTime
                });
                out = (out !? { out - 1 }) ?? { ~data.score.size - 1 };
                ~data.score[in..out].do { |ev| ev[k] = j };
                ~data.lookup[k] = ~data.lookup[k].add(in);
            };
        };


        ~iteratorStream = ~iteratorPattern.asStream;

        currentEnvironment;
    };

    ~next = { |ev|
        var jump=false, nextPos;
        //If ~nextPos is set, use that instead of iterating
        nextPos = ~nextPos ?? { ~iteratorStream.next };
        ~nextPos = nil; //reset ~nextPos for next time

        ~prevEvent = ~nextEvent;
        ~nextEvent = nextPos !? { ~data[\score][nextPos] };

        if (~nextEvent.notNil) {

            ~nextEvent.putAll(ev, ~protoEvent);
            if ((nextPos - ~prevPos) != 1) {
                jump = true;
            };
            ~prevPos = nextPos;

            ~actionLabels.do { |key|
                var prevIndex, nextIndex = ~nextEvent[key];
                if (~prevEvent.notNil) {
                    prevIndex = ~prevEvent[key];
                };

                //Stop prevIndex if not nil
                if (prevIndex != nextIndex and: { prevIndex.notNil } ) {
                    ~actions[key].onStop(prevIndex);
                };

                //TODO rethink this
                //TODO what should we pass to the functions?
                if (nextIndex.notNil) {
                    //Start if index is not the same
                    if (prevIndex != nextIndex) {
                        ~actions[key].onStart(nextIndex);
                    };
                    if (prevIndex.notNil) {
                        //Change if prev index is not nil
                        ~actions[key].onChange(prevIndex, nextIndex);
                        if (jump) {
                            //if not linear, do the jump action
                            ~actions[key].onJump(prevIndex, nextIndex);
                        }
                    }
                };
            };

            currentEnvironment.changed(\segment, ~nextEvent.startPos, ~nextEvent.dur);
        };

        if (~trace.notNil and: { ~trace }) {
            ~nextEvent.postln;
        };


        ~nextEvent;

    };

    ~reset = {
		var buf, waitTime=0;
        // ~currentEvent !? { waitTime = ~currentEvent.dur };
		"reset".debug;
        ~nextPos = nil;
        ~iteratorStream.reset;
        ~prevPos = -1;
		~nextEvent = nil;
        ~prevEvent = nil;


        ~t.do({ |thing|
            //Free everything that's not a node, or doesn't have a parent group in ~t
            if (thing.respondsTo(\group).not or: {~t.includes(thing.group).not }) {
                thing.free
            }
        });

        ~t = nil;

        ~bufferPool.reset;
        /*
		fork {
			waitTime.wait;
			buf.free;
		};
        */
			//~bufnum.postln;
        ~readyForPlay = false;

    };

    ~prep = { |sync=false|

        ~randSeed !? {
            r = ~randSeed.value; //Could be a function
            thisThread.randSeed_(r);
            Synth(\setRandSeed, [\seed, r]);
        };

        ~t = (); //A holder of temporary items
        ~prepareScore.value;
        //For
        ~t.preGroup = Group();
        //Main pattern is playing here
        ~t.mainGroup = Group.after(~t.preGroup);
        //For fx using signal from main pattern
        ~t.postGroup = Group.after(~t.mainGroup);
        //For send fx, like reverbs
        ~t.sendGroup = Group.after(~t.postGroup);
        //Main output
        ~t.masterGroup = Group.after(~t.sendGroup);
        //Where monitoring happens
        ~t.monitorGroup = Group.after(~t.masterGroup);

        //Main output bus
        ~t.mainOut = Bus.audio(s, 2);
        //Bus for fx that need processing
        ~t.fxOut = Bus.audio(s, 2);

        ~bufferPool.initBuffers(~numBufs, ~soundFile.numChannels);

        //We don't need to sync if offline
		if (~isRendering.not and: { sync }) {
            s.sync;
        };


        //Create main monitors, and mix down to stereo, bus 0

        ~t.monitor = ().make {
            ~main = Monitor();
            ~fx = Monitor();
        };
        ~t.monitor.fx.play(~t.fxOut.index, 2, 0, 2, ~t.monitorGroup, multi:true);
        ~t.monitor.main.play(~t.mainOut.index, 2, 0, 2, ~t.monitorGroup, multi:true);



        ~readyForPlay = true;

        ~onReady.value;

    };

    ~play = { |startEvent=0, clock|
        clock = clock ?? { TempoClock.default };
        if (~streamPlayer.isPlaying.not) {
            var startPos = ~data[~tickLabel][startEvent][0];
            var func = {
                if (~readyForPlay) {
                    ~reset.value;
                };

				~prep.value(true);

                //Maybe better to calculate duration of startEvent and use ffwd instead?
                ~streamPlayer = ~asPattern.value(startEvent).play(clock);
                currentEnvironment.changed(\state, \playing, startPos);
            }.inEnvir;
            if (clock == ScoreClock) {
                func.value;
            } {
                func.fork;
            };
        }

    };

    ~stop = {
        ~streamPlayer.stop;
        // ~reset.value;
        // ~currentEvent.free; //Free currently playing synth
        currentEnvironment.changed(\state, \stopped);
    };

    ~playPause = {

        if (~readyForPlay.not) {
            ~play.value;
        } {
            if (~streamPlayer.isPlaying) {
                ~streamPlayer.pause;
                ~currentEvent.free;
                //Set ~nextPos to current position. Seems more logical to restart
                //on current segment.
                ~nextPos = ~prevPos;
                currentEnvironment.changed(\state, \paused);

            } {
                ~streamPlayer.play;
                currentEnvironment.changed(\state, \playing);
            }
        }
    };

    ~playStop = {
        if (~streamPlayer.isPlaying) {
            ~stop.value;
        } {
            ~play.value
        }
    };

    //Bounce == render
    //By default it creates a 44100/24bit .wav file in /tmp, named with song + timestamp.
    ~bounce = { |opt|
        var score, path;

        score = ~generateScore.value(opt);

        path = opt.path.value;


        score.recordNRT(path ++ ".osc", path, nil,
            opt.sampleRate, opt.headerFormat, opt.sampleFormat,
            ServerOptions().numOutputBusChannels_(~channels), duration:score.score.last[0],
            action: {
                opt.action;
                //Cleanup
                if (opt.deleteScoreFile) {
                    File.delete(path ++ ".osc");
                };
            }
        );

		//For checking score when debugging
		~bounceScore = score;

        ~isRendering = false;
    };

    ~generateScore = { |opt|
        var score;

        opt = opt ? ();

        opt.parent_((
            //path is nil
            basePath: PathName.tmp,
            path: { |ev| ev.basePath +/+ "%_%.%".format(~song, Date.getDate.stamp, ev.headerFormat.toLower) }.inEnvir,
            startPos:0,
            dur:999,
            tail: 10,
            sampleRate: 44100,
            headerFormat: "WAV",
            sampleFormat: "int24",
            deleteScoreFile: true
        ));
        ~isRendering = true;

        //This apparently fixes the ERROR: makeSynthMsgWithTags: buffer overflow bug.
        //For some reason the synthdef loading message (d_recv) becomes too large or something if we don't
        //clear the score first, like this. Then we can ~loadSynthDefs again. This only happens when loading synthdefs
        //right before... :|

        //We do this so bus allocation will not conflict with output buses
        Server.fromName(\ScoreDummy).options.numOutputBusChannels_(~channels);

        ScoreClock.beginScore;
        ScoreClock.addSynthDefs;
        // ~loadSynthDefs.value;

        ~play.value(0, ScoreClock);
        score = ScoreClock.makeScore(opt.dur, opt.tail);
        ~stop.value;
        ~isRendering = false;
        score;
    };

    //Re-add synthdefs for rendering
    ~loadSynthDefs = {
        //Variable is set in top of file
        synthDefsPath.load;
    };

    ~asPattern = { |drop=0|
        var reset = ~reset.inEnvir;
        var tail = ~data.tail ? 0;
        Pspawner({ arg sp;
            var parStream;
            ~spawner = sp;
            //reset function
            sp.seq(Event.silent(0, (addToCleanup: {
                reset.value
            })));
            parStream = sp.par(~parPtn);
            sp.seq(Pchain(
                ~modPtn,
                Prout(e { |ev| loop { ev = ~next.value(ev).yield }})
            ).collect({ |ev|
                //XXX maybe this shouldn't be done
                ev.startPos = ev.startPos - (ev.fadeTime ? 0.002);
                //cue sound file as the very last thing to happen
                //So we can modulate startPos before
                if (ev.type == \monoSet) {
                    ev[\bufnum] = ~currentEvent.bufnum;
                } {
                    ev[\bufnum] = ~bufferPool.next(~soundFile, ev.startPos);
                };
                ~currentEvent = ev
            }).drop(drop));
            sp.suspend(parStream);
            tail.wait;
            sp.suspendAll; //Hack, otherwise stream will never reset when ending by itself
        }.inEnvir);
    };

    ~update = { |obj, what ... args|

        if (what == \position) {
            var segment = ~data[~tickLabel].flop[0].select({ |x| x < args[0] }).size - 1;
            if (~isRendering.not and: { ~streamPlayer.isPlaying }) {
                ~stop.value;
                fork {
                    0.3.wait;
                    ~play.value(segment);
                };
	    	} {
                ~play.value(segment);
            }

        }
    };

	//Play single segment (for debugging)
	//needs a ~prep before!
	~playSegment = { |seg = 0 |
		if (~protoEvent[\bufnum].notNil) {
			~nextPos = seg;
			~next.(()).make({ ~group = nil }).play;
		}
	};

    //Set next position
    //Tries to be close enough when using random patterns as iteratorPattern
    ~setNextPos = { |target|
        var val, closest, lastClosest, i=0,
        //Max tries to find the right value in stream
        maxTry=1e+6;
        ~iteratorStream.reset;
        val = closest = ~iteratorStream.value;
        while {
            (val == target or: {
                lastClosest.notNil and: {
                    abs(val - target) <= abs(lastClosest - target)
                }
            }).not
        } {
            i = i + 1;
            if ( abs (val - target) < abs (closest - target)) {
                closest = val
            };
            val = ~iteratorStream.next;
            if ( val.isNil or: { i > maxTry } ) {
                ~iteratorStream.reset;
                i = 0;
                lastClosest = closest;
                // lastClosest.debug("lastClosest");
                // "iteration".debug;
            };
        };

        ~nextPos = val;

    }

});
