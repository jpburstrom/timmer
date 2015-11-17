// quick example to show use of BoidRoids class
c = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/hits/*")
(
SynthDef(\test, { |bufnum=0, bufrate=1, amp=1, pan=1, delay=0, hit|
    var snd = PlayBuf.ar(2, bufnum, bufrate * TRand.kr(0.99, 1.01)) * EnvGen.kr(Env.perc(TRand.kr(0, 0.01), TRand.kr(0.3, 0.4), 1, 0), doneAction:2);
    snd = snd + (0.4 * PlayBuf.ar(1, hit) * EnvGen.ar(Env.perc(0, 0.12)));
    // snd = snd.clip2(TRand.kr(0.01, 0.05));
    snd = LPF.ar(snd, TExpRand.kr(15000, 20000));
    snd = Pan2.ar(Mix(snd), pan, amp);
    snd = DelayC.ar(snd, 1, delay);
    Out.ar(0, snd)
}).add;


SynthDef(\test2, { |bufnum=0, bufrate=1, amp=1, pan=1, delay=0, rate=3, lpf = 20000,hpf=5, trig=(-1)|
    // var trig = Impulse.ar(rate);
    var trigger = Trig.ar(trig, 2.5);
    var snd = PlayBuf.ar(1, bufnum, bufrate, trigger);
    // snd = snd + (0.4 * PlayBuf.ar(1, hit) * EnvGen.ar(Env.perc(0, 0.12)));
    // snd = snd.clip2(TRand.kr(0.01, 0.05));
    // snd = LPF.ar(snd, TExpRand.kr(15000, 20000));
    snd = Pan2.ar(Mix(snd), Lag.kr(pan, 0.1), Lag.kr(amp, 0.1));
    snd = DelayC.ar(snd, 1, Latch.kr(delay, trig).lag(0.01));
    snd = HPF.ar(LPF.ar(snd, Lag.kr(lpf, 0.1)), Lag.kr(hpf, 0.1));
    snd = snd;
    Out.ar(0, snd)
}).add
)



(
var numboids, boids, run, w, m, boidcolour, maxvel, current, update, synths;

var gui = true;

numboids = 40;
run=true;
boids=BoidRoids(numboids);
boids.separation(0.5);
boids.alignment(0.1);
boids.coherence(2);
boids.inertia(0.013);
boids.friction(0.7);
boids.septhresh(0.215);
maxvel = 0.9;
boids.maxvel(maxvel);
boids.gravity(10);
boids.gravpoint(0.5,0.5);

boidcolour = Array.fill(numboids,{Color.rand});

if (gui) {
    w = Window.new.front;
    w.view.background_(Color.white);

    //posX, posY, velX, velY
    w.drawFunc = {
        var rect = Rect(50, 50, 50, 50);
        var theseboids = current.copy;
        // theseboids[0][0].postln;
        QPen.fillRect(rect);
        numboids.do{ |i|
            var point = Point(theseboids[i][0], theseboids[i][1]).linlin(0,1,0,400);
            QPen.fillColor = boidcolour[i];
            QPen.use{
                QPen.fillOval(
                    Rect(theseboids[i][0].linlin(0,1,0,400),
                        theseboids[i][1].linlin(0,1,0,400),
                        theseboids[i][2].linlin(0,maxvel/2,10,100),
                        theseboids[i][3].linlin(0,maxvel/2,10,100))
                );
                QPen.perform(\fill);
            };
        };
    };
    { while ({ run }) { w.refresh; (1/24).wait;} }.fork(AppClock);
    w.onClose_({run=false; synths.do(_.free)});

};

update = {
    var amp, pan, delay, rate, distance, lpf, hpf, trig;
    current = boids.getBoids;
    // current.postln;
    s.makeBundle(0.2, {
        current.do { |x, i|
            pan = x[0].linlin(0,1,-1,1);
            distance = x.keep(2).asPoint.distanceFrom(0.5@1).linlin(0, 1.118, 0, 1);
            amp = distance.range(1,0.1).cubed;
            delay = distance.range(0, 0.2);
            rate = distance.range(2, 2);
            lpf = distance.range(0.1, 1).linexp(0.1, 1, 4000, 20000);
            hpf = distance.range(0.1, 1).linexp(0.1, 1, 100, 5);
            if (x[2]+x[3] > (maxvel * 0.1999)) {
                trig = 1;
            } {
                trig = -1;
            };
            // lpf.postln
            // [amp, pan].postln;
            // synths[i].postln;
            synths[i].set(\amp, amp, \pan, pan, \delay, delay, \rate, rate, \lpf, lpf, \hpf, hpf, \trig, trig);
            // i.postln;
        }
    });
};

s.makeBundle(0.2, {
    synths = numboids.collect { |i| i.postln; Synth(\test2, [\bufnum, c[i]]) };
});

{ while ({ run }) {
    update.();

    /*boids.separation((boids.myseparation * 10) + 0.0001);
    // boids.myseparation.postln;

    if (boids.myseparation > 0.9) {
        run = false;
    };*/

    (1/24).wait;
}
}.fork;

);

