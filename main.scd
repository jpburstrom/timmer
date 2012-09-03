//********
// LOADING
//********

(
Server.local.options.device = "JackRouter";
s.waitForBoot {
	BP.freeAll;
	
	~dir = ();
	~q = ();
	~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
	~dir.lib = ~dir.project ++ "lib/";
	
	//Load lib files 
	
	(~dir.lib ++ "*").loadPaths;
}
)

~q.s.banks.hits.choose().asBuffer(s)
SoundFile
Synth.new("timmer.hit", [\bufnum, ~q.s.banks.hits.choose()]);


(
BP(\midiTest).free;
PR(\midiWrapper).v.clone({
	
	~playerPattern = { BP(\test) } ;
// (~dir.project ++ "live.scd").loadPaths;
	
	
}) => PR(\midiTest).subType_(\timmerMidi) => BP(\midiTest)
)

s.boot
BP(\test).play
BP(\midiTest).asPattern
BP(\test).amp_(Pkey(\pos))

Pkey
BP(\tm).setEmbedBP(\test)

BP(\tm).stop
BP(\tm).embed(\test)
BP(\tm).amp_(Pkey(\pos))
BP(\tm).play

Pbind (\note, Pseq([1,3,4,5,6], inf)).play


p.asPattern.isStream
\

Pbind(\BP(\tm))
BP(\tm).playing

BP(\tm).size

//~show.start

//
// 3.1
//

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


Ndef(\sine).play
Ndef(\sine).fadeTime = 0.1;
Ndef(\sine, { SinOsc.ar([350, 351.3], 0, 0.2) });
Ndef(\sine).free;
