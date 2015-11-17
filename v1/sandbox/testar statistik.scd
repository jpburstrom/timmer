[(degree: 7, x: 4), (degree: 8, x: 5), (degree: -2, dur: 2.5)].flopDict;
[(degree: 7, x: 4), (degree: 8, x: 5), (degree: -2, dur: 2.5)].flopDict(false);

n = NetAddr("localhost", 4444)
(
//x = Synth(\default);
//y = Synth(\default);
{
    var v, rand = Pbrown().asStream;
    var sec = RingBuffer(10);
    var secavg=0;
    var sec10 = RingBuffer(50);
    var sec10avg=0;
    var test=0;


    loop {
        test = secavg;

        v = rand.next;
        sec.overwrite(v);
        secavg = sec.mean;

        sec10.overwrite(v);
        //sec10avg = sec10.asArray.median;
        //n.sendMsg(\delta, (sec10avg - test) > 0);
        n.sendMsg(\raw, v);
        n.sendMsg(\mean, sec10.mean);
//        n.sendMsg(\median, sec10.asArray.median);
        //n.sendMsg(\midrange, [sec10.minItem, sec10.maxItem].mean);
        n.sendMsg(\geoMean, sec10.geoMean);
        //n.sendMsg(\sec10, sec10avg);
        //x.set(\freq, v.range(64, 72).midicps);
        //x.set(\amp, (1 - [sec10.minItem, sec10.maxItem].mean.range(0.25, 0.75)).cubed);
        0.1.wait;
    }

}.fork
)
n.sendMsg(\raw, 0.99);

Array.rand(10, 0, 1.0).sum / 10

[1,2,3].putLast(4).remove(0)

r = RingBuffer(10)
11.do { r.overwrite(0.rrand(10)) } ; r


r.sum / 10

[2,4].geoMean

