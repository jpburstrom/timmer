// quick example to show use of BoidRoids class
c = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/hits/*")


(
var numboids, boids, run, w, m, boidcolour, maxvel, current, update;

numboids = 2;
run=true;
boids=BoidRoids(numboids);
boids.separation(0.2);
boids.alignment(0.3);
boids.coherence(0.1);
boids.inertia(0.13);
boids.friction(0.5);
boids.septhresh(0.15);
maxvel = 0.8;
boids.maxvel(maxvel);
boids.gravity(0.1);
boids.gravpoint(0.5,0.5);

boidcolour = Array.fill(numboids,{Color.rand});

w = Window.new.front;
w.view.background_(Color.white);

boids.getBoids.postln;
//posX, posY, velX, velY
w.drawFunc = {
    var rect = Rect(50, 50, 50, 50);
    var theseboids = current.copy;
    // theseboids[0][0].postln;
    QPen.fillRect(rect);
    numboids.do{ |i|
        var point = Point(theseboids[i][0], theseboids[i][1]).linlin(0,1,0,400);
        ~makeSound.value(i, theseboids);
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

update = {
    var amp, pan;
    current = boids.getBoids;

    current.do { |x, i|
        amp = x[i][1].cubed;
        pan = x[i][0].linlin(0,1,-1,1)
        Synth(\test, [\bufnum, c[i], \amp, amp, \pan, pan]);
        i.postln;
    }
};

{ while { run } { w.refresh; (1/24).wait;} }.fork(AppClock);
{ while { run } {
    update.();

    (1/12).wait;
}
}.fork;
w.onClose_({run=false});
);
