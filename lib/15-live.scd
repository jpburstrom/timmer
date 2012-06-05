
~timmer = BP(\q).clone({
	~bus = Bus.audio(s, 2);
	//~group = Group(addAction:\addToTail);
	~prep = {
		~trigBus = Bus.control(s, 1);
		//~freqBus = Bus.control(s, 1);
		~ampBus = Bus.control(s, 1);
		{
		SynthDef(\bassTrig, { |amp = 0, inChannel=1|
			var in;
			in = In.ar(~bus, 2);
			Out.kr(~trigBus, Coyote.kr(in[1]));
			Out.kr(~ampBus, Amplitude.kr(in[1], 5, 5));
			Out.ar(0, in[1] * amp);
		}).add;
		SynthDef(\bassTrig2, { |amp = 0, inChannel=1|
			var in;
			in = SoundIn.ar(1); //Piezo
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
		~parent[name] = SynthDef(name, { |out=0, gate=1, mul=1, fadeTime=1|
			var outs, in, trig, amp;
			trig = In.kr(~trigBus); //Dessa kan komma både från live och sonny
			amp = In.kr(~ampBus);	// "
			in = In.ar(~bus, 2); //Den här kommer bara från sonny
			outs = SynthDef.wrap(func, lags, [in, trig, amp]);
			Out.ar(out, mul * outs * EnvGen.kr(Env.asr(fadeTime, 1, fadeTime), gate, doneAction:2));
			Out.ar(~bus, in);
		});
		//Ndef.new(name, ~parent[name]);
	}

});

{
	s.sync;
	~timmer.prep;
	~timmer.trigFactory(\directOut, {|in, trig, amp| in[0].dup }); 

	~timmer.trigFactory(\mel1, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Dxrand([64, 62, 60, 69].midicps, inf));
		son = SinOscFB.ar(freq, 0.2, mul:amp).dup
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});

	~timmer.trigFactory(\mel2, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Drand(([64, 62, 60, 69] - 9).midicps, inf));
		son = SinOscFB.ar(freq, 0.2, mul:amp).dup
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});
	
	~timmer.trigFactory(\melLong, {|in, trig, amp|
		var freq, son;
		freq = Demand.kr(trig, 0, Dseq((~d.swed019w * 32 + 50).round.midicps, inf));
		son = SinOsc.ar(freq, mul:amp).dup
		//Mix.new(SinOsc.ar({4.collect{330}}, mul:0.4 * amp)) ! 2
	});
	
	~timmer.trigFactory(\silence, {|in, trig, amp|
		DC.ar(0)
	});





}.fork
