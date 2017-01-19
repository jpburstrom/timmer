(
"lib/init".import;
q.player.actionLabels = #[onset];
q.player.tickLabel = \onset;
q.player.loadData("10");
q.player.channels = 4; //Normal + Warp
);

(
q.player.setIterator(p { |ev|
    var i = 0, last = 276; //Remove last segment

    var time = thisThread.seconds;

    i = last.rand;

    while {(thisThread.seconds - time) < 300} {
        var tmp = i;
        if (0.1.coin) {
            tmp = 0.rrand(i);
        };
        ev = tmp.debug("onset").yield;
        if (0.99.coin) {
            i = i + 1;
        } {
            i = i - 3.rrand(4);
        };
        i = i.wrap(0, last - 1)
    };

    last.yield

});

q.player.setPtn(Pbind(
    \warp, Pseg(Pwrand([0, 1], [0.9, 0.1], Pwhite(0.01, 1), inf), 1).trace,

    \instrument, Pif(Pfunc( { |ev| ev.warp == 0 } ), \bufSegment, \bufSegmentFreqSplitShiftMS),
    \dur, Pfunc { |ev| ((1-ev.warp) * ev.dur) + (ev.warp * 0.125) },
    \legato, 1 + (Pkey(\warp) * 0.25),
    \ffreq, 392, //G3
    \freqshiftDev, Pwhite(0.95, 1.05),
    \maxFreqshift, -10000,
    \freqshift, Pif(Pfunc { |ev| ev.warp == 0 }, 0, Pn(Plazy { |ev|
        var base = -97.99;
        var maxi = (ev.maxFreqshift / base).floor.abs.asInt;
        Pseries(base, base, maxi)
})) * Pkey(\freqshiftDev),
    \outbus, Pif(Pfunc { |ev| ev.warp == 0 }, 0, 2),
    \freqshiftAmp, Pkey(\freqshift).linexp(-10000, 0, 16, 1),
    \timingOffset, 0.1

));
/*
q.player.parPtn = Ptpar([0.1,Pbind(
    \instrument, \sinewave,
    \freq, Pwhite(94.0, 98),
    \attack, Pwhite(0.0, 0.1),
    \release, 1,
    \db, -42,
    \dur, Pfunc { ~currentEvent.dur }
)]);
*/
)


/*EOF*/

q.player.play

q.player.bounce

