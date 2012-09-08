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


//Select and play events from Pdef
~p.u.evS = { |ev, label|
	var w, layout, player, buttons, dropValue=0;
	var pdef = Pdef(label);
	var play = {
		player.stop;
		player = Pdrop(dropValue, Pbindf(
			pdef,
			\guiStep, Pseries(),
			\guiButtons, Pfunc( { |ev| dropValue = buttons[ev.guiStep].focus; } ),
			)).play
	};

	w = Window("Events for Pdef: " ++ label.asString , Rect(1000,-800,396,210), resizable:false);
	layout = w.addFlowLayout;
	Button(w.view, 190@20).states_([["Play"]]).action_({ |v|
		play.()
	});
	Button(w.view, 190@20).states_([["Stop"]]).action_({ |v|
		player.stop;
	});
	buttons = 64.collect({ |i|
		ActionButton(w.view, i.asString, { dropValue = i; play.() }, 44)
	});

	//do something

	w.front;
	w.onClose = { player.stop };
}
