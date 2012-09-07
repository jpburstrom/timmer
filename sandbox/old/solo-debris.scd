b = Buffer.readChannel(s, "/Users/johannes/samples/libraries/TheRecordist_UltimateWood/WOOD BranchLogDryCrack SBPWD1_ 032.wav",channels:[0]);
a = "/Users/johannes/samples/field/zoom/042-lulea-vasterbotten/010-sly-träsk-water-foot-bra-sly-bra.wav"
a= "/Users/johannes/samples/field/zoom/042-lulea-vasterbotten/013-spång-walk-wood-cars-forest-end_spång.wav"
b = Buffer.readChannel(s, a, channels:[0]);
BufRd.ar(2, b, Phasor.ar(trig, 
		LFNoise2.ar(1, 0.1, 0.1) / SampleRate.ir) * BufFrames.ir(b)) 
		* Lag.kr(amp , LFNoise1.kr(1, 0, 5)).poll;


(
(
~timmer.trigFactory(\timmerDebris, { |in, trig, amp|
var rate;
trig = DelayN.kr(trig, 3, amp * 3);
trig = Dust.kr((LFNoise2.kr(1, 50, 50) * EnvGen.kr(Env.perc(0.01, TRand.kr(0.2, 2, trig)), trig)).poll);
amp * 2 * GrainBuf.ar(2, trig, TRand.kr(0.1,0.4,trig), b, TRand.kr(0.3,0.5,trig), TRand.kr(0,1,trig), envbufnum: z )
}
)
)

t = ~timmer.timmerDebris.play
t.free;
b.play

(
//Spång
//---------------------
var winenv;
winenv = Env.triangle;
winenv.plot;
z = Buffer.sendCollection(s, winenv.discretize);
a= "/Users/johannes/samples/field/zoom/042-lulea-vasterbotten/013-spång-walk-wood-cars-forest-end_spång.wav";
b = Buffer.readChannel(s, a, channels:[0]);
{
var rate, trig, amp, imp, test;
//trig = DelayN.kr(trig, 10,Random);
//trig = Dust.kr(50 * EnvGen.kr(Env.perc(0.01, amp * TRand.kr(0.5, 1, trig)), trig));
trig = Dust.kr(2);
//trig = Formlet.ar(trig);
test = (GrainBuf.ar(2,//NumChannels 
	trig, //Trigger
	10, //Duration 
	b, //Buffer
	TRand.kr(0.45,1.5,trig), //Rate 
	TRand.kr(0,1,trig).poll, // Pos
	4, //Interp
	TRand.kr(-0.2, 0.2,trig), //Pan
	z //Envbufnum
	) * 8).tanh;

//(amp.dup * trig);
}.play

)