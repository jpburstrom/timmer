
BP.freeType(\timmerMidi);


//NOTE: This should be a singleton
//Checking for stop and start
BP(\midiClockCheck).free;
PR(\abstractProcess).v.clone( {
	
	~rolling = false;
	
	~tick = { |index, data|
		
		// ~rolling.postln;
		((9 < index) && (index < 13)).if {
			~rolling = (#[10,11]).includes(index)	;
			//~rolling.postln;
		}
	};
	
	~isRolling = {
		~rolling
	}
}) => PR(\midiClockCheck) => BP(\midiClockCheck);

MIDIIn.sysrt = { |src, index, data|
	//index.postln;
	BP(\midiClockCheck).tick(index, data);
};

//Hey hey
//This is a wrapper for patterns that start and stop on program changes
//Useful variables: 
	//chan (midi channel), 
	//pgm (program change to activate pattern), 
	//posCC (2 nrpn-style CC's giving current position in pattern (should send from 0-16383)
	//pos (giving current position from 0 to 1, if you send posCC)
	//autoplay (if you want to start and stop patterns on program change)
	//Using BP(\midiClockCheck) to check if transport is rolling, so you need to send midi clock as well.
	
PR(\abstractProcess).v.clone(
	{
		//~event = (eventKey: \dummy);
		~chan = 0;
		~pgm = 1;
		~posCC = #[3,35];
		~autoplay = true;
		
		
		//internal
		~ccr = Array.fill(2);
		~ccval = Array.fill(2, 0);
		~pgmr = nil;
		~pos = 0;
		~playing = false;
		//~rolling = false;
		
		~prep = {
			~ccr[0] = CCResponder(e { |src, chan, num, value|
				~ccval[0] = value;
				}, nil, ~chan, ~posCC[0]);
			~ccr[1] = CCResponder(e { |src, chan, num, value|
				~ccval[1] = value;
				~pos = ((~ccval[0] * 128) + ~ccval[1]) / 16384;
				}, nil, ~chan, ~posCC[1]);
			~pgmr = ProgramChangeResponder(e { |src, chan, val|
				~playing = (val == ~pgm);
			}, nil, ~chan)
		};
		
		~freeCleanup = {
			//"Frreeeing".postln;
			~ccr.do(_.remove);
			~pgmr.remove;
		};
		~thisPattern = {
				Pbind(
				\type, \empty,
				\dur, 0.041666667, // 24 fps 
				\playing, Pfunc( e { ~playing && BP(\midiClockCheck).isRolling }Ê) ,
				\pos, Pfunc( e { ~pos }Ê),
				\test, 0
			)
		};
		
		~embedPattern = {
			Pbind()
		};
		
		~embed = { |bp|
			(bp.isSymbol).if ( {
				~embedPattern = { BP(bp) }
			}, {
				~embedPattern = { bp }
			});
			~embedPattern
		};	
		
		//Run embedded pattern when midi circumstances are right
	
		~asPattern = {
			Pif(Pfunc( e {~playing && BP(\midiClockCheck).isRolling } ), 
				Pchain(~embedPattern.value, (type: \note), ~thisPattern.value), 
				~thisPattern.value
				)
		}
			
}) => PR(\midiWrapper).subType_(\timmerMidi);

/*
Small tut:
BP(\tm).free;
PR(\midiWrapper) => BP(\tm);
BP(\tm).embed(\mySpecialBP) //embed BP
BP(\tm).play
//Wait for midi input

//Then you can do things like
BP(\test).amp_(Pkey(\pos)) //Pick keys from midiWrapper stream
//Eeh i guess there could be more midi inputs as well, but don't know

//In the end:
BP(\tm).stop
*/
