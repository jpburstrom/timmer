/*
IN
Sonny
Timmer
|||||
12345
*/
RedMaster

(
~timmer.trigFactory(\testing, {|in, trig, amp|
	SinOsc.ar(mul:0.01)
})

~timmer.trigFactory(\membrane, { |in, trig, amp, hip=400|
	var sig = (BLowPass.ar(Dust.ar(20), 200, 0.4) * 10).tanh;
	var tens = Demand.kr(trig, 0, Dxrand([0.005,0.008,0.006], inf));
	//sig = in;
	MembraneCircle.ar(sig, LFNoise1.kr(1, 0.0003, 0.003), LFNoise1.kr(0.2, 0.00009, 0.9997))})

)

//All Synth/Ndefs are set in 15-live
//TODO: duplicate sonny, both from in 0 och 1

//Part 1
//Sync. Sine. Mel Long. Piezo => Sine. Minimal.
	//TODO: levels
//-Pedal
//Sync. Sine x2. Mel long + cell? Piezo => Sine. Minimal. Change is in electrics
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
------------------------------------------

Ndef(\input, \bassTrig2);
Ndef(\fx, ~timmer.melLong).play;
Ndef(\fx2, ~timmer.mel2).play
Ndef(\fx2, ~timmer.mel2).stop




Ndef(\fx3, ~timmer.directOut).play; s.queryAllNodes

Ndef(\fx, 0);
s.queryAllNodes;

Ndef(\fx).play(addAction:\addToTail).fadeTime = 2;
Ndef(\fx2).play(group: ~timmer.group).fadeTime = 2;
Ndef(\fx3).play(group: ~timmer.group).fadeTime = 2;

s.meter

Ndef(\fx, ~timmer.bassTrigTest)
Ndef(\fx, ~timmer.directOut)
Ndef(\fx, ~timmer.testing)
Ndef(\fx3).stop

s.queryAllNodes

s.defaultGroup = ~timmer.group

~timmer.group.moveAfter(~sonny.group)
~timmer.d

t = Group(addAction: \addToHead)