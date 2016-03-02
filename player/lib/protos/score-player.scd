var songBasePath = "../../songs".resolveRelative;
var dataBasePath = "../../data".resolveRelative;

p = Proto({
    var count = -1;

    ~soundFile = nil;
    ~songPath = nil;
    ~dataPath = nil;
    ~data = ();

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

    //Event things
    ~protoEvent = (instrument:\bufSegment);

    //Dictionary of key => pattern to modify ~nextEvent with
	~modPtn = EventPatternProxy(Pbind());



    //Set iterator pattern
    ~setIterator = { |ptn|
        ~iteratorPattern.source_(ptn);
    };

	~setPtn = { |ptn|
		~modPtn.source_(ptn);
	};

	//TODO: Find good, useful features
	~features = [Loudness, [MFCC, 10]];

	~extractFeatures = {

		f = SCMIRAudioFile(~songPath, ~features);
		f.extractFeatures();

		//Make segments with 5 frames from every onset
		if (~data.onset.notNil) {
			f.gatherFeaturesBySegments(~data.onset.collect { arg x; [x[0], x[0] + (44.1/1024*5)] });
			~data.featureClump = f.featuredata.clump(f.numfeatures).collect { |x, i| x ++ i };
			~data.kdTree = KDTree(~data.featureClump, lastIsLabel:true);
		};
	};

    //Load data from song label
    //song is folder in dataBasePath,
    //or first match of dash-terminated prefix of song file basename (eg 01 => 01-song-name-year-month-day-time.wav")
    ~loadData = { |song|
        ~dataPath = dataBasePath +/+ song;
        ~songPath = (songBasePath +/+ song ++ "-*.wav").pathMatch[0];
        SoundFile.use(~songPath, { |sf|
            ~soundFile = sf;
            ~actionLabels.do { |k|
                var path = ~dataPath +/+ k ++ ".txt";
                if (File.exists(path)) {
                    var tmp, durations, data = TabFileReader.read(path);
                    //If we only have one time value per row, we calculate durations
                    if (data[0].size == 1) {
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
                                //Check if numeric
                                if ("^(?=.)([+-]?([0-9]*)(\\.([0-9]+))?)$".matchRegexp(x)) {
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
            //for some reason proto_ doesn't work...
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
        ~currentEvent !? { waitTime = ~currentEvent.dur };
		"reset".debug;
        ~nextPos = nil;
        ~iteratorStream.reset;
        ~prevPos = -1;
		~nextEvent = nil;
        ~prevEvent = nil;

        ~t.do(_.free);

        buf = ~protoEvent[\bufnum];
		fork {
			waitTime.wait;
			buf.free;
		};
			//~bufnum.postln;
        ~readyForPlay = false;
    };

    ~play = {
        "play".debug;
        {
            ~t = (); //A holder of temporary items
            ~prepareScore.value;
            ~t.preGroup = Group();
            ~t.mainGroup = Group.after(~t.preGroup);
            ~t.postGroup = Group.after(~t.mainGroup);
			~protoEvent[\bufnum] = Buffer.read(s, ~songPath);
            s.sync;
            ~readyForPlay = true;
            ~onReady.value;
            ~streamPlayer = ~asPattern.value.play;
            currentEnvironment.changed(\state, \playing);
        }.inEnvir.fork
    };

    ~stop = {
        ~streamPlayer.stop;
		//TODO reset after finished playing
        ~streamPlayer.reset;
        currentEnvironment.changed(\state, \stopped);
    };

    ~playPause = {

        if (~readyForPlay.not) {
            ~play.value;
        } {
            if (~streamPlayer.isPlaying) {
                ~streamPlayer.pause;
                currentEnvironment.changed(\state, \paused);

            } {
                ~streamPlayer.play;
                currentEnvironment.changed(\state, \playing);
            }
        }
    };

    ~asPattern = {
        var reset = ~reset.inEnvir;
        Pspawner({ arg sp;
            ~spawner = sp;
            //reset function
            sp.seq(Event.silent(0, (addToCleanup: reset)));
            sp.par(~parPtn);
			sp.seq(Pchain(~modPtn, Prout(e { |ev| loop { ev = ~next.value(ev).yield }})));


        }.inEnvir).collect({ |ev| ~currentEvent = ev });
    };

    ~update = { |obj, what ... args|

        if (what == \position) {
            var segment = ~data[~tickLabel].flop[0].select({ |x| x < args[0] }).size - 1;
            ~setNextPos.value(segment);
            if (~streamPlayer.isPlaying.not) {
                ~play.value;
            };


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
