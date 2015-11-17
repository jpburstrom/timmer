SynthDef("timmer.grainX", { arg distance=1, revOutG=2, revOutL=4, startPos, dur, bufnum, bufRate = 1, pan = 0, attack = 0.1, decay = 0.02, curve, out;
	var env, l, r, panspec, hpspec, lpspec, fakedistance, widthspec, hp, lp, amp, revamp, revampG, revampL, width, sound;
	
	//pan.poll(Impulse.kr(10));
	//Fade in _before_ grain start
	startPos = startPos * BufFrames.kr(bufnum);
	
	lpspec = ControlSpec(20000, 1000, \exp);
	hpspec = ControlSpec(40, 500, \exp);
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
	width = -1;
	//pan = pan * (width.abs * 0.5 + 0.5);
	
	sound = PlayBuf.ar(2, bufnum, bufRate * BufRateScale.kr(bufnum), 1, startPos, 0)
		* EnvGen.ar(Env.perc(attack, decay, curve: curve), doneAction: 2);
	#l, r = LPF.ar(HPF.ar(sound, hp), lp);
	sound = [LinXFade2.ar(l, r, width), LinXFade2.ar(r, l, width)];
	sound = Pan2.ar(sound, [(pan - 1).clip(-1,0), (pan + 1).clip(0, 1)]).sum;
	OffsetOut.ar(out, sound);
	OffsetOut.ar(revOutG, sound * revampG);
	OffsetOut.ar(revOutL, sound * revampL);	
}).add; 


