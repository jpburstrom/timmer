~p.u = ();

~p.u.svdur = Proto({
	~path = nil;
	~durs = [];
	//Normalized as in if 0 is first event or not.... silly name.
	~normalized = false;
	~samplerate = 48000;

	~open = { |basename|
		var base = topEnvironment[\p].s.currentPath;
		~samplerate = SoundFile.use( base +/+ "samples" +/+ basename, (_.sampleRate));
		~path = base +/+ "data" +/+ basename.splitext[0] ++ ".onsets";
		~durs = FileReader.read(~path).collect(_[0].asFloat);
		currentEnvironment;
	};

	//duration in secs
	~durations = { |n=false|
		n.if {
			~durs - ~durs[0]
		} {
			~durs
		}
	};

	//durations in frames
	~frames = {
		(~durs * ~samplerate).round;
	};

	//durations as 
	~durationsNormSum = {
		~durs.normalizeSum;
	};

	~asPattern = {
		var p;
		var d = ~durations.(~normalized);
		~normalized.if {
			p = Pbind( \dur, Pseq(d.differentiate.drop(1)))
		} {
			p = Pbind( \dur, Pseq(([0] ++ d).differentiate.drop(1)))
		};
		p
	};
	
	~asStream = {
		~asPattern.().asStream
	};

	//return envelope with durations as peaks
	~peakEnv = { |peak=1,low=0.01,curve=\sin, from, division=#[0.25, 0.5, 0.25]|
		var durs = ~durs.differentiate.drop(from);
		var levels;
		levels = (durs.collect { [peak, low, peak] }).flatten;
		durs = durs.collect( _ * division  ).flatten.drop(1);
		Env(levels, durs, curve);
	}

});

//Simple REAPER controller
~p.r !? { ~p.r.ddr.free };
~p.r = Proto ({ 
	~ddr = NetAddr("localhost", 57121);
	~playing = false;

	~play = e { |time|
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
//Shortcut
~p.rp = { e { |v| ~r.play(v) }  };

//Stop Reaper on Cmdperiod
CmdPeriod.add( e { ~p.r.stop } );

(

~p.wrapper = Proto({ 

	~pattern = Pbind();
	~onCounter = (1: {"tetst".postln});
	~onEvery =  {};
	~onFirst =  {};
	~dropValue = 0;

	~asPattern = {
		Pbindf(
			~pattern,
			\gui, Prout( ~guiCallback.() ),
			\counter, Pseries(),
			\routine, Pfunc ( e { |ev|
					~onCounter[ev.counter].(ev);
					~onEvery.(ev);
					(ev.counter == ~dropValue).if { ~onFirst.(ev) };
					true;
				})
			).dropDo(~dropValue, topEnvironment[\p].rp)
	};

	~asStream = {
		~asPattern.().asStream
	};

	~guiDefaultCallback = { { loop { false.yield } } };
	~guiCallback = ~guiDefaultCallback; 
	
	~showGui = {
		var  buttons, w, layout; 
		topEnvironment[\p].rendering.not.if {
			~window !? { ~window.front };
			~window ?? {
				w = Window("Events for Pdef: " ++ ~label.asString , Rect(1000,-800,396,210), resizable:false);
				layout = w.addFlowLayout;
				Button(w.view, 190@20).states_([["Play"]]).action_( e { |v|
					~playP.(~dropValue)
				});
				Button(w.view, 190@20).states_([["Stop"]]).action_( e { |v|
					~stopP.()
				});
				buttons = 64.collect({ |i|
					ActionButton(w.view, i.asString, e { ~dropValue = i; ~playP.(i) }, 44)
				});
				w.front;
				~guiCallback = e { { i=0; loop { ~dropValue = i;  buttons[i].focus; i.yield; } } };

				w.onClose = e { ~window = nil; ~stop.(); ~guiCallback = ~guiDefaultCallback; };
				~window = w;
			}
		}
	};

	~playP = {|time|
		CmdPeriod.run; 
		topEnvironment[\p].r.play(time);
		~player = EventPatternProxy(~asPattern.()).play;
		
	};

	~stopP = {
		~player !? { ~player.stop };
		topEnvironment[\p].r.stop;
		CmdPeriod.run; 
	}

});

);


/*
~p.meap.open("impulse-strak.wav.feat")
~p.meap.start(0.2) //single item
~p.meap.length //array
*/

~p.meap = Proto({
	~meap; 

	~open = { |file|
		~meap = MEAPSoft.new.loadFEAT(topEnvironment[\p].s.currentPath +/+ "data" +/+ file);
	};

	~start = { |index = -1|
		var d = ~meap.featDict[\AvgChunkPower];
		(index < 0).if { 
			d.collect(_.segTime) 
		} {
			index = (index * d.size).round.min(d.size - 1);
			d[index].segTime
		}
	};

	~length = { |index = -1|
		var d = ~meap.featDict[\AvgChunkPower];
		(index < 0).if { 
			d.collect(_.segLength) 
		} {
			index = (index * d.size).round.min(d.size - 1);
			d[index].segLength
		}
	};

})


