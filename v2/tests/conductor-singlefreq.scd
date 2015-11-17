(
Conductor.make({ |con, baseNote, harmonic, freq, preamp, phase|
    c = con;
    baseNote.sp(43, 0, 127, 1);
    harmonic.sp(1, 1, 8, 1);
    freq.spec_(\freq);
    preamp.sp(1, 0, 8);
    phase.sp(0.16, 0, 1);
    con.synth_((
        instrument: \bandy,
        group: q.settings.syngrp,
        delayOffset: q.settings.rtlatency),
    [freq: freq, preamp: preamp, phase: phase]
    );
}).show;
c[\harmonic].action_ { |cv| c[\freq].value = cv.value * c[\baseNote].value.midicps };
c[\baseNote].action_ { |cv| c[\freq].value = cv.value.midicps * c[\harmonic].value };
c[\baseNote].value_(43);
)