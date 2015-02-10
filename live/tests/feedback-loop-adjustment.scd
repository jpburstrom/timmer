(
SynthDef(\recipTest, { |freq, periodAdjust, gate=1|
    var in, imp, sound;
    var extradelay, rtdelay = Control.ir(0.01);
    var period = freq.reciprocal;
    extradelay = (period - rtdelay) % period;
    extradelay = extradelay + (period * periodAdjust);
    //extradelay.poll;

    in = LocalIn.ar(1) * 1;
    in = DelayC.ar(in, 0.2, rtdelay - ControlDur.ir);
    //Add impulse
    in = in - (SinOsc.ar(freq, 0, \amp.kr) * EnvGen.ar(Env.perc(0.1, 0.2), Impulse.ar(0)));


    //in = BPF.ar(in, freq, 0.1);

    //Add extra delay
    LocalOut.ar(DelayC.ar(in, 0.1, extradelay)); // for feedback
    in = in * Linen.kr(gate, 0, 1, 0.1, 2);
    Out.ar(0, in)
}).add
)

~
//Live test
(
//rtdelay =
SynthDef(\recipTestLive, { |freq, periodAdjust, gate=1, rtdelay = 0.01|
    var in, imp, sound;
    var extradelay;
    var period = freq.reciprocal;
    var inChannel = 0;
    var outChannel = 0;
    extradelay = (period - (rtdelay * 0.01)) % period;
    extradelay = extradelay + (period * periodAdjust);

    //extradelay.poll(1, \extraDelay);

    in = SoundIn.ar(inChannel) * 1;
    //Add impulse
    in = in + (SinOsc.ar(freq, 0, \amp.kr) * EnvGen.ar(Env.perc(0.1, 0.2), Impulse.ar(0)));


    //Add extra delay
    Out.ar(outChannel, DelayC.ar(in, 0.1, extradelay)); // for feedback
    in = in * Linen.kr(gate, 0, 1, 0.1, 2);

}).add
)
(
Conductor.make({ |con, delay, periodAdjust, midinote|
    con.pattern_(
        Pbind(
            \instrument, \recipTestLive,
            \midinote, midinote,
            \amp, 0.6,
            \legato, 1,
            \dur, 2,
            \periodAdjust, periodAdjust,
            \rtdelay, delay
        )
    );
    delay.sp(q.settings.rtlatency * 100, 0, 100, 0.01);
    periodAdjust.sp(0, 0, 1, 0.001);
    midinote.sp(36, 36, 80, 1);
}).show;
)
BusMeters(s, [Bus()]).gui(nil, Rect(0, 0, 50, 400)).start