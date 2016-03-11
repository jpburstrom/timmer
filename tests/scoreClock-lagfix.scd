(
//Overriding \schedBundleArray in event to make ScoreClock work with \lag
//Because lag is scheduled on SystemClock, we add lag to offset
//so everything will be scheduled once on ScoreClock
//Doesn't yet work with array args
Pbind(\lag, Pn(0.1, 1), \schedBundleArray, #{ | lag, offset, server, bundleArray, latency |
    if (lag > 0) {
        offset = offset + ScoreClock.secs2beats(lag);
    };
    //Always set lag to 0
    schedBundleArrayOnClock(offset, thisThread.clock, bundleArray, 0, server, latency)
}).play(ScoreClock);

~score = ScoreClock.makeScore;
~score.recordNRT("/tmp/test.osc", "/tmp/test.aif");
)
