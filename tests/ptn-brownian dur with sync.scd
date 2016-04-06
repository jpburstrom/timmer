(

//Pattern 2 is synced with pattern 1 durations

//Wrap Ptpar in a Penvir to allow data sharing between patterns
Penvir((), Ptpar([
	0.0, Pbind(
		\note, Pseq([0,-2,-4,5,3], inf),
		\octave, 4,
		\dur, Pwhite(2, 5.0),
		\legato, 0.5,
		\timingOffset, 0.1
	).collect({ |ev| ~lastEvent = ev }),
	0.1, Pbind(
		\note, Pxrand([0,3,7], inf),
		\legato, 2,
		\dur, p { |ev|

			//Min and max durations
			var max = 0.5;
			var min = 0.2;
			//Brownian motion step size
			var step = 0.05;

			var mean = (max + min) * 0.5;

			var dur, val=mean, last, i;
			var setVal = { val = (val + step.rand2).fold(min, max); };

			loop {
				//Pick up duration from parallel pattern
				dur = ~lastEvent.dur;
				i = 0;
				//Select how many notes should be a part of the non-random sequence to finish with
				last = 1.rrand(4);
				setVal.value;
				//Yield new random durations while remaining duration is enough
				while { (dur - val) > (mean * last) } {
					dur = dur - val;
					ev = val.yield;
					//Update mean to be a moving average of a couple of previous values
					mean = (0.75 * val) + (0.25 * mean);
					setVal.value;
				};
				//And yield `last` number of equal-sized durations to finish up
				last.do {
					ev = (dur / last).yield
				}

			}
	}
	)

])).play

)
