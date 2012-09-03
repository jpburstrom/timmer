~p.s.buf = ();
~p.s.bus = ();
~p.s.syn = ();



~p.freeAll = {
	~s.buf.asArray.do(_.free);
	~s.buf = ();
	~s.bus.asArray.do(_.free);
	~s.bus = ();
	~s.syn.asArray.do(_.free);
	~s.syn = ();
};


~p.readBuffer = { |label, path|
	~s.buf[label.asSymbol].free;
	~s.buf[label.asSymbol] = Buffer.read(s, path);
};
~p.addBuffer = { |label, buffer|
	~s.buf[label.asSymbol].free;
	~s.buf[label.asSymbol] = buffer;
};

~p.makeBus = { |label, channels=1|
	~s.bus[label.asSymbol].free;
	~s.bus[label.asSymbol] = Bus.audio(s, channels) 
};

~p.playSynth = { | label, synthDef, args, target, addAction='addToHead' |
	~s.syn[label.asSymbol].free;
	~s.syn[label.asSymbol] = Synth(synthDef, args, target, addAction)
};

//Init
~p.toPrep = ();

~p.addPrep = { |label, fun, prio=10|
	~toPrep[label.asSymbol] = [fun, prio];
};
~p.prep = {
	~freeAll.();
	e {
		s.sync;
		~toPrep.asArray.sort({|x, y| x[1] > y[1]}).do( { |x| x[0].value; s.sync; } );
	}.fork
};

~p.restart = { 
	e {
		s.sync;
		~toPrep.asArray.select({|x| x[1] == 0}).do( { |x| x[0].value; s.sync; } );
	}.fork
};

~p.getBuf = { |label|
	~s.buf[label]
};

~p.getBus = { |label|
	~s.bus[label]
};

~p.getSyn = { |label|
	~s.syn[label]
};

CmdPeriod.add( e { ~p.restart } );

