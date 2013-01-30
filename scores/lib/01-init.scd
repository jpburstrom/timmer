~p.s.buf = ();
~p.s.bus = ();
~p.s.syn = ();
~p.s.bank = ();
~p.rendering = false;
~p.isPrepped = false;

~p.freeAll = {
	(~rendering == false).if {
		~s.buf.asArray.do(_.free);
		~s.buf = ();
		~s.bank.asArray.do { |x| x.do(_.free) };
		~s.bank = ();
		~s.bus.asArray.do(_.free);
		~s.bus = ();
		~s.syn.asArray.do(_.free);
		~s.syn = ();
	}
};


~p.readBuffer = { |label, path|
	(~rendering == false).if { ~s.buf[label.asSymbol].free };
	(path[0] != "/").if {
		path = ~s.currentPath +/+ "samples" +/+ path;
	};
	~s.buf[label.asSymbol] = Buffer.read(s, path);
};
~p.addBuffer = { |label, buffer|
	(~rendering == false).if { ~s.buf[label.asSymbol].free };
	~s.buf[label.asSymbol] = buffer;
};

~p.readBank = { |label, path|
	(~rendering == false).if { ~s.buf[label.asSymbol].do(_.free) };
	(path[0] != "/").if {
		path = ~s.currentPath +/+ "samples/banks" +/+ path +/+ "*";
	};
	~s.bank[label.asSymbol] =  SoundFile.collectIntoBuffers(path)

};

~p.makeBus = { |label, channels=1|
	(~rendering == false).if { ~s.bus[label.asSymbol].free };
	~s.bus[label.asSymbol] = Bus.audio(s, channels) 
};

~p.playSynth = { | label, synthDef, args, target, addAction='addToHead' |
	(~rendering == false).if { ~s.syn[label.asSymbol].free };
	~s.syn[label.asSymbol] = Synth(synthDef, args, target, addAction)
};

//Init
~p.toPrep = ();

~p.addPrep = { |label, fun, prio=10|
	~toPrep[label.asSymbol] = [fun, prio];
};

~p.prep = { |callback|
	var clock;
	~rendering.if { 
		clock = ScoreClock; 
	} { 
		clock = TempoClock; 
	};
	e {
		~toPrep.asArray.sort({|x, y| x[1] > y[1]}).do( { |x| x[0].value; 0.00001.wait; } );
		callback.value;
		~isPrepped = true;
	}.fork(clock)
};

~p.run = { |callback|
	callback !? {
		~runCallback = callback;
	};
	~isPrepped.if {
		~runCallback.value
	} {
		~prep.(~runCallback);
	}
};

~p.restart = { 
	e {
		~toPrep.asArray.select({|x| x[1] == 0}).do( { |x| x[0].value;} );
	}.defer(0.1);
};

~p.getBuf = { |label|
	Pfunc( e { ~s.buf[label] })
};
~p.getBus = { |label|
	Pfunc( e { ~s.bus[label] })
};

~p.getSyn = { |label|
	Pfunc( e { ~s.syn[label] })
};

~p.doRender = {  arg pattern, path, maxTime=60, sampleRate = 44100,
			headerFormat = "AIFF", sampleFormat = "int16", options, inputFilePath, action;
	var score, server, initialSilence=1;
	maxTime = maxTime + initialSilence;
	~freeAll.();
	~rendering = true;
	ScoreClock.beginScore;
	ScoreClock.tempo = 1;
	(~s.currentPath +/+ "scores/lib/02-synthdefs.scd").load;

	~prep.();
	topEnvironment.make({
		Pseq([
			Pbind(\type, \rest, \dur, Pseq([initialSilence])), 
		  Pfindur(maxTime, pattern)
		]).play(ScoreClock);
	});
	//recordNRT crashes when putting in a pattern longer than ScoreClock's internal maxTime,
	//so we need to make maxTime greater than Pfindur + rest above;
	score = ScoreClock.makeScore(maxTime + initialSilence);//.postcs;
	score.score.do(_.postln);
	//score.postln;
	score.render(path, maxTime, sampleRate, headerFormat, sampleFormat, options, inputFilePath, action);
	~rendering = false;
	~freeAll.();
	~prep.();
};



CmdPeriod.add( e { ~p.s.syn = ();  ~p.restart } );

Server.default = Server.local

