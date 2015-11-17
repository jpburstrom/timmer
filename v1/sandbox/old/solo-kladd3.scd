c = Buffer.cueSoundFile(s, "/Volumes/HD2/projects/timmer/creations/bryggen-20110519/01-Stall-110519_1550.wav",0,1)
c.cueSoundFile("/Volumes/HD2/projects/timmer/creations/bryggen-20110519/01-Stall-110519_1550.wav")

(
//Server.local.options.device = "JackRouter";

s.waitForBoot {
	BP.freeAll;
	
	~dir = ();
	~q = ();
	~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
	~dir.lib = ~dir.project ++ "lib/";
	
	//Load lib files 
	
	(~dir.lib ++ "*").loadPaths;
	
	
	
	SynthDef(\bassTrig, { |trigBus, ampBus|
		var in;
		in = SoundIn.ar(1);
		//in = VDiskIn.ar(1, c, BufSampleRate.kr(c) / SampleRate.ir, 1);
		Out.kr(trigBus, Coyote.kr(in));
		//# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
		//freq.poll;
		//Out.kr(freqBus, freq);
		Out.kr(ampBus, Amplitude.kr(in, 5, 5));
		//Out.ar(0, in.dup);
	}).add;
	
	s.sync;
	
	~timmer = BP(\q).clone({
		
		~test = "foo";
		
		~prep = {
			~trigBus = Bus.control(s, 1);
			//~freqBus = Bus.control(s, 1);
			~ampBus = Bus.control(s, 1);
		
			~bassTrig = Synth.new(\bassTrig, [\trigBus: ~trigBus, \ampBus, ~ampBus]);
			
			~trigFactory.(\timmerBranches, {|in, trig, amp|
				BufRd.ar(2, b, Phasor.ar(trig, 
					LFNoise2.ar(1, 0.1, 0.1) / SampleRate.ir) * BufFrames.ir(b)) 
					* Lag.kr(amp , LFNoise1.kr(1, 0, 5)).poll;
			}); 
		};		
		
		~trigFactory = { | name, func, lags=nil |
			"This is the Trig Factory".postln;
			~parent[name] = SynthDef(name, { |out=0|
				var outs, in, trig, amp;
				trig = In.kr(~trigBus);
				amp = In.kr(~ampBus);
				in = SoundIn.ar(1);
				outs = SynthDef.wrap(func, lags, [in, trig, amp]);
				Out.ar(out, outs);
			})
		}
	});
	
	~timmer.prep();
		
}
)

//Wrap synthdefs in this function
~timmer.trigFactory(\bassTrigTest, {|in, trig, amp|
	var freq;
	freq = Demand.kr(trig, 0, Dseq((~d.swed019w * 32 + 50).round.midicps, inf));
	SinOsc.ar(freq, mul:amp)	
})

s.meter
t = ~timmer.bassTrigTest.play
t.free

b = Buffer.read(s, "/Users/johannes/samples/libraries/TheRecordist_UltimateWood/WOOD BranchLogDryCrack SBPWD1_ 032.wav",);
(
/*
~timmer.prep();
*/

~timmer.trigFactory(\timmerBranches, {|in, trig, amp|
	Select.kr(trig
	BufRd.ar(2, b, Phasor.ar(trig, 
		LFNoise2.ar(1, 0.1, 0.1) / SampleRate.ir) * BufFrames.ir(b)) 
		* Lag.kr(amp , LFNoise1.kr(1, 0, 5)).poll;
}); 
t = ~timmer.timmerBranches.play
t.free
)


{VDiskIn.ar(1, c, BufSampleRate.kr(c) / SampleRate.ir, 1); }.play