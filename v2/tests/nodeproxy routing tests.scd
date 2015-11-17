Ndef(\test, { SinOsc.ar(2.pow(\freqMod.kr(0) * 0.083333333) * 440) * 0.1 }).play
    2.pow(-1)
Ndef(\test).sources
Ndef(\mod, { SinOsc.kr(1, mul: 2/12) }) <>>.freqMod Ndef(\test)

2.midiratio

2.pow(2/12)
Ndef(\mod, 0)

Ndef(\cv) <>>.freqMod Ndef(\test)
x
x.source = { LFNoise2.kr(1).range(-2,2) }
Ndef(\test).map(\freqMod, nil)
Ndef(\test).orderNodes(x)

Ndef(\test).playN([0,1])

c = CV(\bipolar)
Ndef(\cv, { \freqMod.kr });
c.action_ { |x| Ndef(\cv).set(\freqMod, x.value) }

x = NodeProxy(s, \control);
x.source = c.asStream
c.value = -1

g = EZSlider(controlSpec: c.spec).front
c.connect(g)



  -24.dbamp