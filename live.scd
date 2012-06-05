/*
The show
---------------------

IN
Sonny
Timmer
|||||
12345
*/
//All Synth/Ndefs are set in 15-live
//Part 1
	//TODO: levels
//-Pedal
//Part 2: Sync. Sine x2. Mel long + cell? Piezo => Sine. Minimal. Change is in electrics
	//TODO: möjligtvis någon längre crescendo-drone?
//-Pedal
//Room 1. What? Statiskt. bassolo.
//-Pedal
//Sonny. Direct out.
//-Tid + Pedaluppsläppning
//Room 2. 
//-Pedal
//Sonny. Mel 1 + Mel 2. Ev mel 2 efter en stund.
//-Tid + Pedaluppsläppning
//Room 3
//-Pedal
//------------------------------------------ 

c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/023-move-chemal-crickets+river/006-water-environment-distant-insects-.wav" , 0, 2);

~show = ~timmer.clone({	
	~pedals = [
		{|val| 
			if ( val == 0, { ~sonny.play },{ ~sonny.stop} )
		},
		e {|val|
			if (val == 0, { ~next.() });
		},
		e {|val|
			~next.();
		}
	];
	
	~currentCue = 0;
	~cueOrder = [\part1, \part2, \room, \sonnyDirect, \room2, \melody1, \room3, \theEnd];
		
		
	~start = {
		"-----------SHOW STARTS HERE-----------".postln;
		MIDIdef.cc(\timmerPedal, ~pedals[1], 64); 
		Ndef(\input, \bassTrig2);
		Ndef(\fx, ~silence).play.fadeTime=4;
		Ndef(\fx2, ~silence).play.fadeTime=4;
		Ndef(\room, ~silence).play.fadeTime=4;
		~currentCue = 0;
	};
	~quiet = {
		"Quiet".postln;
		Ndef(\fx, ~silence);
		Ndef(\fx2, ~silence);
	};
	~part1 = { 
		"Part 1".postln;
		Ndef(\input, \bassTrig2); 
		Ndef(\fx, ~melLong).vol = 0.02;
	};
	~part2 = { 
		"Part 2".postln;
		//Ndef(\input, \bassTrig2); 
		//Ndef(\fx, ~melLong).set(\mul, 0.2).play;
		Ndef(\fx2, ~mel2).vol = 0.069;
		c = Buffer.cueSoundFile(s,"/Users/johannes/samples/field/zoom/023-move-chemal-crickets+river/006-water-environment-distant-insects-.wav" , 0, 2);
	};
	~room = {
		"Room".postln;
		Ndef(\room, ~rooms).vol = 0.19;
		Ndef(\fx, ~silence);
		Ndef(\fx2, ~silence);
	};
	~sonnyDirect = { 
		"Sonny Direct".postln;
		MIDIdef.cc(\timmerPedal, ~pedals[0], 64);
		topEnvironment[\sonny].play; //HACK
		//Ndef(\input, \bassTrig2); 
		Ndef(\fx, ~directOut).vol = 0.3;
		Ndef(\fx2, ~silence);
		Ndef(\room, ~silence);
		{ 	
			180.wait; //180??
			c.cueSoundFile("/Users/johannes/samples/field/zoom/023-move-chemal-crickets+river/002-calm-environment-crickets-outside-nature.wav");
			"Waiting for pedal".postln;
			MIDIdef.cc(\timmerPedal, ~pedals[2], 64); 
		}.fork
	};
	~room2 = {
		"Room 2".postln;
		Ndef(\room, ~rooms).vol = 0.35;
		Ndef(\fx2, ~silence);
		Ndef(\fx, ~silence);
		MIDIdef.cc(\timmerPedal, ~pedals[1], 64); 
	};
	~melody1 = {
		"Melody 1".postln;
		Ndef(\room, ~silence); //Fix this
		MIDIdef.cc(\timmerPedal, ~pedals[0], 64); 
		Ndef(\input, \bassTrig);
		Ndef(\fx, ~mel1).vol=0.1;
		Ndef(\fx2, ~silence).vol=0.1;
		{ (50.rrand(70)).wait; ~melody2.() }.fork
	};
	~melody2 = {
		"Melody 2".postln;
		//Ndef(\fx, ~mel1);
		Ndef(\fx2, ~mel2);
		{ 	
			120.wait; //120?
			c.cueSoundFile("/Users/johannes/samples/field/zoom/023-move-chemal-crickets+river/004-bra-paus-crickets-clear-crisp-environment-paus-solo-environment-flying.wav");
			"Waiting for pedal".postln;
			MIDIdef.cc(\timmerPedal, ~pedals[2], 64); 
		}.fork
	};
	
	~room3 = {		
		Ndef(\room, ~rooms).vol = 0.068; //Fix this
		Ndef(\fx, ~silence);
		Ndef(\fx2, ~silence);
		"Room 3".postln;
		
	};
	
	~theEnd = {
		Ndef(\fx, ~silence);
		Ndef(\fx2, ~silence);
		Ndef(\room, ~silence);
		MIDIdef(\timmerPedal).free; 
	};
	~next = {
		~cueOrder[~currentCue] ?? { "End of show".postln };
		currentEnvironment[~cueOrder[~currentCue]].();
		~currentCue = ~currentCue + 1;
	};
	
	~rooms = { |mul = 0.2|
		var in, in2, chain, chain2;
		in = VDiskIn.ar(2, c, BufSampleRate.kr(c) / SampleRate.ir, 1);
		chain2 = FFT(LocalBuf([16384,16384]), in);
		PV_MagClip(chain2, 0.01);
		chain = FFT(LocalBuf([128,128]), in, 0.5);
		PV_BrickWall(chain, 0.01);	
		PV_MaxMagN(chain, 4);
		PV_SpectralEnhance(chain, 4, 3, 0.35);
		((IFFT(chain2)*0) + IFFT(chain) * 3).tanh * mul;
	}
});

{
3.wait;
~show.start
}.fork