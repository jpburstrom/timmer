~p.u = ();
~p.u.svdur = Proto({
	~path = nil;
	~durs = [];
	~normalized = false;

	~open = { |path|
		~path = path;
		path.postln;
		~durs = FileReader.read(~path).collect(_[0].asFloat);
		currentEnvironment
	};

	~durations = { |n=false|
		n.if {
			~durs - ~durs[0]
		} {
			~durs
		}
	};

	~asPattern = {
		var d = ~durations.(~normalized);
		Pbind( \dur, 
			Pseq(d.differentiate.drop(~normalized.asInteger))
		)
	};
	~asStream = {
		~asPattern.().asStream
	}

})

