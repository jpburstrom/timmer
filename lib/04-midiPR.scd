(
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
		~rolling = false;
		
		~prep = {
			~ccr[0] = CCResponder(e { |src, chan, num, value|
				~ccval[0] = value;
				}, nil, ~chan, ~posCC[0]);
			~ccr[1] = CCResponder(e { |src, chan, num, value|
				~ccval[1] = value;
				~pos = ((~ccval[0] * 128) + ~ccval[1]) / 16384;
				//(~pos).postln;
				}, nil, ~chan, ~posCC[1]);
			~pgmr = ProgramChangeResponder(e { |src, chan, val|
				"PMGM".postln;
				(~autoplay && (val == ~pgm) && (false == ~playing)).if {
					"PLAYING".postln;
					~asPattern.value.play
				};
				~playing = (val == ~pgm);
				[~rolling, ~playing].postln
			}, nil, ~chan)
		};
		
		~freeCleanup = {
			//"Frreeeing".postln;
			~ccr.do(_.remove);
			~pgmr.remove;
		};
		
		//Change this for the magic
		~playerPattern = {
			
			Pbind()	
		};
		
		~asPattern = {
			//Reset rolling for every event
			Pwhile1({ ~rolling = BP(\midiClockCheck).isRolling; ~rolling && ~playing}, ~playerPattern.value);
		}
			
}) => PR(\midiWrapper).subType_(\timmerMidi);

PR(\midiWrapper) => BP(\tm)

 )
BP(\tm).playing = true
BP(\tm).play
BP(\tm).playing = false

