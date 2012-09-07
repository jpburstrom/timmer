(

//Ugly fast sync from Reaper

~player = Proto.new (Ê{
	~upcomingEvent = 0;
	
	~events = [
		[7.2, { "test".postln }],
		[9.2234234234, { "test2".postln }]
	];
	
	~start = {|time|
		~upcomingEvent = ~events.flop[0].indexOfGreaterThan(time);
	};

		
	~makeWindow = {
		var window = Window.new("",Rect(318, 686, 275, 40)).front;
		window.name("Time");
		window.addFlowLayout( 10@10, 20@5 );
		~label = StaticText.new(window.view, 200@20)
			.font_(Font.new("Anonymous Pro", 18, true))
			.string_(0);
	};
	
	~makeWindow.();
	
	OSCdef.new(\play, e { |msg|
		OSCFunc(e { |msg|
			~start.(msg[1])
		}, '/time').oneShot;  
	}, '/play');
	
	OSCdef.new(\timeWindow, e { |msg|
		var time = msg[1];
		~events[~upcomingEvent] !? {Êif(~events[~upcomingEvent][0] < time, e { 
			~events[~upcomingEvent][1].value; ~upcomingEvent = ~upcomingEvent + 1 
		} ) };
		e { ~label.string_(time) }.defer;
	}, '/time');
	
})

)
