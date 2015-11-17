~input = Bus.audio();
~output = Bus.audio();


SynthDef(\bandy, { |freq=100, delayOffset=0.0094, phase=0.8|
    var in = SoundIn.ar(0);
    var period = freq.reciprocal;

    //Calculate "phase" for frequency
    var delay = Lag.kr((((delayOffset - (period * phase)) * freq).ceil * period) + ( period * phase), 0.1);
    \
    in = BPF.ar(in * \preamp.kr(0.0), freq, \rq.kr(0.0289));
    in = DelayC.ar(in, 0.1, delay);
    Out.ar(\out.kr, in);
}).add;

x = { SinOsc.ar(\freq.kr(440) + (\amp.kr(0) * \freq.kr), 0) * 0.1 }.play

x.free

b = Bus.audio(s)
c = Bus.audio(s)
c

x.set(\amp, z.asMap)

a = { SinOsc.ar(330) * 0 }.play(s, b)
a.free

Ndef(\fm, {
    var snd = In.ar(c);
    snd * 36.midicps.reciprocal * \amp.kr(0.1);
});
Ndef(\fm).gui
Ndef(\fm).play(b.index, 1, q.tree.ctlgrp, addAction:\addToHead)
Ndef(\fm).addSpec(\amp, [0, 10, \lin, 0.01])

q.tree.synths[\36].set(\delayMod, b.asMap)
q.tree.synths[\38].set(\delayMod, b.asMap)
q.tree.synths[\43].set(\out, 32)
q.tree.synths[\81].set(\out, 36)
q.tree.synths[\55].set(\out, 32)
195.cpsmidi
36+19