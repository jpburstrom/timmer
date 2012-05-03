
~timmer = BP(\q).clone({
	~bus = Bus.audio(s);
	//~group = Group(addAction:\addToTail);
	~prep = {
		~trigBus = Bus.control(s, 1);
		//~freqBus = Bus.control(s, 1);
		~ampBus = Bus.control(s, 1);
		{
		SynthDef(\bassTrig, { |amp = 0, inChannel=1|
			var in;
			in = In.ar(~bus);
			Out.kr(~trigBus, Coyote.kr(in));
			Out.kr(~ampBus, Amplitude.kr(in, 5, 5));
			Out.ar(0, in * amp);
		}).add;
		SynthDef(\bassTrig2, { |amp = 0, inChannel=1|
			var in;
			in = SoundIn.ar(0);
			Out.kr(~trigBus, Coyote.kr(in));
			Out.kr(~ampBus, Amplitude.kr(in, 5, 5));
			Out.ar(0, in * amp);
		}).add;
		s.sync;
		Ndef(\input, \bassTrig);
		}.fork
	};		
	
	~trigFactory = { | name, func, lags=nil |
		"This is the Trig Factory".postln;
		~parent[name] = SynthDef(name, { |out=0, gate=1, fadeTime=1|
			var outs, in, trig, amp;
			trig = In.kr(~trigBus);
			amp = In.kr(~ampBus);
			in = In.ar(~bus);
			outs = SynthDef.wrap(func, lags, [in, trig, amp]);
			Out.ar(out, outs * EnvGen.kr(Env.asr(fadeTime, 1, fadeTime), gate, doneAction:2));
			Out.ar(~bus, in);
		});
		//Ndef.new(name, ~parent[name]);
	}

});

{
	s.sync;
	~timmer.prep;
	~timmer.trigFactory(\directOut, {|in, trig, amp| in }); 

	~timmer.trigFactory(\mel1, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Dxrand([64, 62, 60, 69].midicps, inf));
		son = SinOscFB.ar(freq, 0.2, mul:amp)
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});

	~timmer.trigFactory(\mel2, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Drand(([64, 62, 60, 69] - 9).midicps, inf));
		son = SinOscFB.ar(freq, 0.2, mul:amp)
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});
	
	~timmer.trigFactory(\melLong, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Dseq((~d.swed019w * 16 + 55).round.midicps, inf));
		son = SinOscFB.ar(freq, 0.2, mul:amp)
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});
	









}.fork
