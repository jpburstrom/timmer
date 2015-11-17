(
~woodfilter = { |input|
        var freqs, rqs, output;
        // Note: these freqs are as given in the diagram:
        freqs = [62.5, 125, 250, 395, 560, 790];
        // The Q values given in the diagram (we take reciprocal, since that's what BPF unit wants)
        rqs   = 1 / [1, 1, 2, 2, 3, 3];
        // in the text, andrew says that the freqs follow these ratios,
        // which give a very different set of freqs...:
        // freqs = 125 * [0.5, 1, 1.58, 2.24, 2.92, 2, 2.55, 3.16];

        //Now let's apply the parallel bandpass filters, plus mix in a bit of the original:
        output = BPF.ar(input, freqs, rqs).sum ;

};

// Now let's use this function in something - some dust impulses tap-tap-tapping on the door:
x = {
        Pan2.ar(~woodfilter.value(  LPF.ar(Dust.ar(10), 10000)  ))
}.play;
// Doesn't sound much like a door? Compare it to the raw tapping sound (edit the above).
)

(
~stickslip = { |force|
        var inMotion, slipEvents, forceBuildup, evtAmp, evtDecayTime, evts;
        force = force.lag(0.1); // smoothing to get rid of volatile control changes

        inMotion = force > 0.1; // static friction: nothing at all below a certain force

        // slip events are generated at random with freqency proportional to force.
        // I originally used Dust to generate random events at a defined frequency, but
        // that lacks the slight "pitched" sound of the creaky door. Here we use Impulse
        // to generate a frequency, but we add some noise to its frequency to try and
        // avoid it getting too perfectly regular.
        slipEvents = inMotion * Impulse.ar(force.linlin(0.1, 1, 1, 1/0.003) * LFDNoise1.ar(50).squared.linexp(-1,1, 0.5, 2).poll);

        forceBuildup = Phasor.ar(slipEvents, 10 * SampleDur.ir, 0, inf).min(1);

        // Whenever a slip event happens we use Latch to capture the amount of
        // force that had built up.
        evtAmp = Latch.ar(Delay1.ar(forceBuildup.sqrt), slipEvents);
        evtDecayTime = evtAmp.sqrt;
        // The book applies square-root functions to shape the dynamic range of the events.
        // Remember that square-root is computationally intensive, so for efficient
        // generation we might want to change it to (e.g.) a pre-calculated envelope.

        // Now we generate the events
        evts = EnvGen.ar(Env.perc(0.001, 1), slipEvents, evtAmp, 0, evtDecayTime * 0.01);
};
// Let's plot 4 seconds worth, with steadily increasing force.
// Events should appear more frequent but less violent as the plot progresses.
{~stickslip.value(Line.kr(0,1,4))}.plot(4);
)


(
~squarepanel = { |input|
        var times, filt;
        // times in milliseconds, converted to seconds:
        times = [4.52, 5.06, 6.27, 8, 5.48, 7.14, 10.12, 16] * 0.001;
        filt = DelayC.ar(input, times, times).mean;
        filt = HPF.ar(filt, 125);
        filt * 4
};
)

x = {~squarepanel.value(~woodfilter.value(~stickslip.value(MouseX.kr(0,1))))}.play