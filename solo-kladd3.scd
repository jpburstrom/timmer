c = Buffer.cueSoundFile(s, "/Volumes/HD2/projects/timmer/creations/bryggen-20110519/01-Stall-110519_1550.wav",0,1)
c.cueSoundFile("/Volumes/HD2/projects/timmer/creations/bryggen-20110519/01-Stall-110519_1550.wav")

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