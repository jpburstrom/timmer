~p.u = ();
~p.u.svdur = Proto({
	~path = nil;
	~durs = [];
	~normalized = false;

	~open = { |path|
		~path = path;
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
	~routines = (1: {"tetst".postln});
	~dropValue = 0;

	~asPattern = {
		Pbindf(
			~pattern,
			\gui, Prout( ~guiCallback.() ),
			\routine, p ( {
				i = 0;
				loop { 
					~routines[i].value;
					i = i+1;
					i.yield;
				}
			}.inEnvir )
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


