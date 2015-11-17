(
p.stop;
~freqs = (1..12).collect { arg i; i * ([28,33,38,43].midicps) }.flop;
//~freqs = ~freqs.collect { arg f, i; [f, ~freqs[(i+12).wrap(0, ~freqs.size - 1)] ]};
~freqs.postln;
p = Pbind(\string, Pseq([0,3], inf),
    \partial, Pwhite(0, 6),
    \amp, Pfuncn({|ev| 0.01 / (1 + ev.partial)}, inf),
    \legato, 1,
    \instrument, \sinTest,
    \freq, Pfuncn({|ev|~freqs[ev.string][ev.partial]}, inf),
    \dur, 0.2).play
)
    Pwalk

~bfs = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/hits/*");

(
var w = Window();
var synths = ();
var current = Set();
var saved = List();
var freqs = (1..16).collect { arg i; i * ([28,33,38,43].midicps) }.flop;
var btns = freqs.collect({ arg str, strnum;
        str.collect({ arg p, num;
        var lab = p.round(0.01).asSymbol;
        Button().states_([[lab, Color.grey], [lab, Color.blue]]).action_( { |b|

            if (b.value == 1,  {
                synths[lab] = Synth(\sinTest, [\amp, 0.01 * (num + 1).reciprocal, \freq, p, \dur, 120]);
                (btns.flop[num] ++ btns[strnum]).reject( { arg x; x == b } ).do(_.valueAction_(0));
                current.add([p, num]);
                current.postln;
            }, {
                    synths[lab].set(\gate, 0);
                    synths[lab] = nil;
                    current.remove(p);
            });
        });
    });
});

var freebtn = Button().states_([["Free"]]).action_({
    btns.do { arg cols; cols.do { arg btn; btn.valueAction_(0) } }
});
var savebtn = Button().states_([["Save"]]).action_({
    saved = saved.add(current.asArray);
    saved = saved.asSet.asArray;
    saved.writeArchive("/Volumes/Mega/projects/timmer/kod/sc/data/timmer-klang.archive");

    saved.postln;
});
btns[0].postln;
w.layout = GridLayout.columns([freebtn, savebtn], *btns);
w.front
)

SynthDef(\sinTest, { arg bufnum, freq, amp, dur, fb=0.1, attack = 1, release=1, gate=1;
    var out = Decimator.ar(SinOscFB.ar(freq, fb * 0, mul: amp), 48000, 12) * EnvGen.kr(Env.adsr(attack, dur, 1, releaseTime:release, curve:-24), gate, doneAction:2);
    out = out + (PlayBuf.ar(2, bufnum, startPos:4000) * EnvGen.kr(Env.perc(releaseTime:0.1)));
    Out.ar(0, out.dup)
}).add;


(

var freqs = (1..32).collect { arg i; i * ([28,33,38,43].midicps) }.flop;
freqs.postln;

Pbind(\selection, Pstutter(1, Pfunc( { |ev| ev.selection.postln; (1..15).scramble.keep(4) })),
    \instrument, \sinTest,
    \freq, Pfunc( { |ev| ev.selection.collect({ |num, i| freqs[i][num] }) }),
    \dur, 12,
    \attack, 1,
    \legato, 2,
    \pan, [
    \release, 0.1,
    \fb, (Pkey(\selection) + 1).reciprocal * 0.4,
    \amp, 0.05 * (1 + Pkey(\selection)).reciprocal,
    \bufnum,~bfs.scramble.keep(1)
).play

Pxrand
)
Pcollect
[0,2].range

a = { ReplaceOut.ar(0, In.ar(0, 2).tanh ) }.play
a.stop
