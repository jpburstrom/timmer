Server.local.options.device = "JackRouter"

SynthDef("timmer.grain1", { arg startPos, dur, bufnum, bufRate = 1, pan = 0, amp = 1, attack = 0.1, decay = 0.02, out;
	var env, l, r;
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos - attack) * BufFrames.kr(bufnum);	
	#l, r = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.linen(attack, dur, decay), doneAction: 2);
	OffsetOut.ar(out, Balance2.ar(l, r, pan, amp))
}).add;

SynthDef("timmer.grainX", { arg distance=1, revOutG=2, revOutL=4, startPos, dur, bufnum, bufRate = 1, pan = 0, attack = 0.1, decay = 0.02, out;
	var env, l, r, panspec, hpspec, lpspec, fakedistance, widthspec, hp, lp, amp, revamp, revampG, revampL, width, sound;
	
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = (startPos - attack) * BufFrames.kr(bufnum);
	
	lpspec = ControlSpec(20000, 300, \exp);
	hpspec = ControlSpec(40, 1200, \exp);
	widthspec = ControlSpec(-1, 0);
	//distance = MouseY.kr;
	//pan = MouseX.kr(-1, 1);
	hp = hpspec.map(distance);
	lp = lpspec.map(distance);
	fakedistance = (distance * 9 + 1);
	amp = fakedistance.reciprocal;
	revamp = 1 / fakedistance.sqrt;
	revampG = revamp * amp;
	revampL = revamp * 1 - amp;
	width = widthspec.map(distance);
	//pan = pan * (width.abs * 0.5 + 0.5);
	
	sound = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.kr(Env.linen(1, dur, 1), doneAction: 2);
	#l, r = LPF.ar(HPF.ar(sound, hp), lp);
	sound = [LinXFade2.ar(l, r, width), LinXFade2.ar(r, l, width)];
	sound = Pan2.ar(sound, [pan, pan]).sum;
	OffsetOut.ar(out, sound);
	OffsetOut.ar(revOutG, sound * revampG);
	OffsetOut.ar(revOutL, sound * revampL);	
}).send;



b = Buffer.read(s, "/tmp/untitled.wav");
c = Buffer.read(s, "/Volumes/HD2/projects/timmer/render/to SC/v2-3.1-24bit.wav")
d = Buffer.read(s, "/Volumes/HD2/projects/timmer/render/to SC/v2-3.3-24bit.wav");
~clouds = Array.fill(20)

~clouds.do(_.stop);

(
var x = 50;
~clouds = Array.fill(x);
x.do { |i|
	{ 6.0.rand.wait;
	~clouds[i] = GranCloud("timmer.grainX");
	~clouds[i][\bufnum] = d.bufnum;
	// set the center values of the grain attributes (using the bracket shortcut)
	~clouds[i][\rate]      = 7.822;	// grain rate in number of seconds between grain start times
	~clouds[i].dev[\rate]      = 12.221;	// grain rate in number of seconds between grain start times
	~clouds[i][\dur]       = 1;	// duration of the grain envelope in seconds
	~clouds[i][\bufRate]   = 1;	// buf read rate, will correspond to transposition level
	~clouds[i].dev[\pan] = 0;
	~clouds[i][\startPos] = i/x + 0.3.rand - 0.45;
	~clouds[i].duration = inf;
	~clouds[i].def = 'timmer.grainX';
	~clouds[i][\distance] = 1;
	~clouds[i][\pan] = (i/x*2) - 1;
	~clouds[i].dev[\startPos] = 0.05;
	~clouds[i].play(s, 0, nil)
	}.fork
}
)
~clouds
~clouds[3][\pan]
~clouds.do(_.stop)
a.stop


~clouds.do { |x | x.dev[\distance] = 0.2 }
~clouds.do { |x | x.dev[\startPos] = 0.4 }
~clouds.do { |x | x.dev[\rate] = 8.4 }

~clouds.do { |x | x[\rate] = 4.4 }
~clouds.do { |x | x[\distance] = 1 }

~clouds.do { |x | x[\bufRate] = 0.9 }
~clouds.do { |x | x[\decay] = 2.4 }
~clouds.do { |x | x[\attack] = 0.4 }

0.2.rand
s.meter

a[\startPos] = 44510

a.dev[\rate]      = 0.02;	// grain rate in number of seconds between grain start times


Env([0, 1], [ 10 ], 'linear').plot

0.rrand(1.0) 


SynthDef("eqtest", { arg distance=1, pan=0, in=0, out=0, revOutG=2, revOutL=4;
	var panspec, hpspec, lpspec, fakedistance, widthspec, hp, lp, amp, revamp, revampG, revampL, width, sound;
	lpspec = ControlSpec(20000, 600, \exp);
	hpspec = ControlSpec(40, 1200, \exp);
	widthspec = ControlSpec(-1, 0);
	//distance = MouseY.kr;
	//pan = MouseX.kr(-1, 1);
	hp = hpspec.map(distance);
	lp = lpspec.map(distance);
	fakedistance = (distance * 9 + 1);
	amp = fakedistance.reciprocal;
	revamp = 1 / fakedistance.sqrt;
	revampG = revamp * amp;
	revampL = revamp * 1 - amp;
	width = widthspec.map(distance);
	pan = pan * (width.abs * 0.5 + 0.5);
	
	sound = In.ar(in, 2);
	#l, r = LPF.ar(HPF.ar(sound, hp), lp);
	sound = [LinXFade2.ar(l, r, width), LinXFade2.ar(r, l, width)];
	sound = Pan2.ar(sound, [pan, pan]).sum;
	Out.ar(out, sound);
	Out.ar(revOutG, sound * revampG);
	Out.ar(revOutL, sound * revampL);
}).add;



e = Synth(\eqtest, [\in, g], addAction: \addToTail)
e.free
e.set(\distance, 1)
Map
s.meter
s.queryAllNodes