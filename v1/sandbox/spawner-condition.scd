~cues = [\one, \two, \three];

t = Routine({
    ~cues.do { |cue|
        cue.yield
    }
});


(
x = Condition(false);
c = (and: (time: false, blob:true));
t = { arg sym, b;
    c[sym] = b;
    c.postln;
    x.test = c[sym] && false;
    x.signal;
};
{ 3.wait; t.(\time, true) }.fork;
{ 0.5.wait; x.test.postln; x.wait; "Yes".postln; }.fork
)
(
var spawner;
c = Condition();
Pn(
    Pspawner({ |sp|

        spawner = sp;

        c.test = false;
        {
            "Condition checks here".postln;
            4.wait;
            "Sign".postln;
            c.test_(true).signal
        }.fork;

        sp.seq(Pbind(\dur, Pn(1, 1)));
        sp.seq((play: { c.hang }, cond: c, delta:0 ));
        "hello".postln;

    }), 3
).play;

spawner
)
c.test_(true).signal

c.test_({0.rrand(1.0) > 0.5}).signal




