(
~sfplay = Proto({
	
	
	~sf = (test: "sounds/a11wlk01-44_1.aiff");
	~fx = (fm: ( type: \on, instrument: \fm, freq: 4, index: 1, addAction: 1, db: -90));
	~fm = (freq: 2200);
	
	~recreateGroup = {Ê
		"NEEEET WROSP".postln;
		~group = Group.new;
		NodeWatcher.register(~group)	
	};
		
	~makeFunction = {
		var sf;
		var fx;
		
		~group !? ~group.isPlaying.if({}, {~recreateGroup.()});
		~group ?? { "NIL".postln; ~recreateGroup.() };
		
		~fx.keysValuesChange( {Ê|k, v|
			v[\group] = ~group;
		});
		
		sf = ~sf;
		fx = ~fx;
		
		{
			sf.pairsDo( { |label, path|
				currentEnvironment.put(label,  SoundFile(path).asEvent.yield);
			});
/*			
			fx.pairsDo( {Ê| label, ev |
				currentEnvironment.put(label,  ev.yield);
				currentEnvironment.put((label++"Control").asSymbol,  
					[\set, currentEnvironment[label][\id], 
						currentEnvironment[label][\msgFunc] ]);
				currentEnvironment.postln
			});
*/
			~fm = ( type: \on, instrument: \fm, dur: Pseq([3], inf), freq: 220, index: 1, addAction: 1, db: -120).yield;
			~fm.postln;
			~fmControl = [\set, ~fm[\id], ~fm[\msgFunc] ];
		
		}
	};
	
	~fxp = { 
		var set = ~fx.keys.collect { |label|
			currentEnvironment[label].isNil.if( {
				Pbind(#[type, id, msgFunc], Pkey(\fmControl))
			}, {
				"NOTNTIL".postln;
				Pchain(currentEnvironment[label], Pbind(#[type, id, msgFunc], 
					Pkey((label++"Control").asSymbol)))
	     })
		};
		set.asArray
	};
		
	
	~sfp = {	
		~group.postln;
		Pbind(*[
		instrument:	\help_playbuf,
		dur:			Pseg([0,0,0.25,0.5, 0.75, 1],10).linexp(0,1,0.01,2),
		legato:		4,
		startPos:		Pn(Pseg([0,1], 20), inf),
		rate:		Pwhite(1, 1).midiratio,
		loop:		0,
		group: 		~group,
		bufnum:		Pkey(\test)
	
	])};
	
	~freeAll = {
		 ~stop.(); ~group.freeAll; ~group = nil;  ~currentPattern = nil;
	};
	
	~cleanup = {
		e { ~group.free; ~group = nil; ~currentPattern = nil;}
	};
	
	~asPattern = { 
		~currentPattern = Pproto( ~makeFunction.(), Pbind(*[#[type, id, msgFunc], Pkey(\fmControl),
		]).trace, ~cleanup.());
		~currentPattern
	};
	
	~p = {
		~asPattern.()
	};
	
	~play = {
		~p.().play
	};
	
	~stop = {
		~currentPattern !? { ~currentPattern.stop; ~currentPattern = nil}
	};


		
}, parentKeys: #[soundFiles]);

)

~sfplay.play
s.queryAllNodes
~sfplay.stop

~sfplay.currentPattern


~sfplay.fxp.()

Pbind().envir

Node
Set["22"].asArray ++ [2,3,4]

Event
~group = Group.new
~group.nodeID

Pbind(( instrument: \fm, db: -120, amp: 1e-06,   'addAction': 1,  'index': 1, 'freq': 220, 'type': \on ))

