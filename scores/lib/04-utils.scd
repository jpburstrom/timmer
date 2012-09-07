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

});


//Simple REAPER controller
~p.r !? { ~p.r.ddr.free };
~p.r = Proto ({ 
	~ddr = NetAddr("localhost", 57121);
	~playing = false;

	~play = { |time|
		time !? { ~ddr.sendMsg("/time", time); };
		(~playing == false).if {
			~ddr.sendMsg("/play", 1);
		};
		~playing = true;
	};

	~stop = {
		~ddr.sendMsg("/stop");
		~playing = false;
  }
});

//Stop Reaper on Cmdperiod
CmdPeriod.add( e { ~p.r.stop } );

