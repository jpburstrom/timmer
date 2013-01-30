// quick example to show use of BoidRoids class

(
var numboids, boids, run, w, m, boidcolour, maxvel;

numboids = 100;
run=true;
boids=BoidRoids(numboids);
boids.separation(0.5);
boids.alignment(0.3);
boids.coherence(0.5);
boids.inertia(0.3);
boids.friction(0.5);
boids.septhresh(0.02);
maxvel = 0.2;
boids.maxvel(maxvel);
boids.gravity(4);
boids.gravpoint(0.5,0.5);

boidcolour = Array.fill(numboids,{Color.rand});

w = Window.new.front;
w.view.background_(Color.white);

w.drawFunc = {
	var theseboids = boids.getBoids;
	numboids.do{ |i|
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
{ while { run } { w.refresh; (1/24).wait;} }.fork(AppClock);
w.onClose_({run=false});
)