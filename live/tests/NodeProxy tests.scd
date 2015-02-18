//Multiple NPs in same group
~proxies.clear;
fork {
    g = Group();
    NodeWatcher.register(g);
    s.sync;
    s.bind {
        ~proxies = 24.collect{ NodeProxy.audio(s).source_({ DC.ar }).parentGroup_(g).play }
    }
};

//Order of execution
Ndef(\mod, { SinOsc.ar(330) * 0.1 });
Ndef(\car, { Ndef.ar(\mod) * -1 });
//Fix order of execution
Ndef(\mod).group.moveBefore(Ndef(\car).group);
Ndef(\car).play //Should sound
Ndef(\mod).play //Should cancel out


//PM test
Ndef(\mod, { SinOsc.ar(360) });
Ndef(\mod2, { SinOsc.ar(LFNoise2.kr(1).exprange(360, 580)) });
Ndef(\car, { SinOsc.ar(180, \moda.ar * 0.1) });
Ndef(\car).set(\moda, Ndef(\mod2).bus.asMap);
Ndef(\mod2).group.moveBefore(Ndef(\car).group);
Ndef(\car).play
Ndef(\car).stop