MIDIIn.help


(
~pos = Array.fill(8);
~data = Array.fill(7);
MIDIIn.smpte = { arg src, index, data;

	(index < 7).if ({	
		~pos[7-index] = data;
	}, {
		//MSF 
		//Hour 
		~pos[7-index] = (data & 16) + ~pos[7-index+1];
		
		(0..3).do { arg i;
			//~pos[i].postln;
			~data[i] = ~pos[i*2] + ~pos[(i*2)+1]; 
		};
		


		
		//Set framerate
		~data[5] = 24;
		~data[6] = false;
		#[25,30,30].do { arg item, i; 
			(data & (1 << (i + 5)) != 0).if {
				~data[5] = item;
				(i == 2).if { ~data[6] = true; }
			}
		};
		
		//Framecount
		~data[4] = (((((~data[0] * 60) + ~data[1]) * 60) + ~data[2]) * ~data[5]) + ~data[3];
		
		~data.postln;
	});	

}		 
)
MIDIIn.smpte = nil

MIDIIn.sysrt = { arg src, chan, val; 			[chan,val].postln; };
MidiIn.note

1 << 4
(32-16 & (1 << 4))

3 << 5
48 & (1 << 7) 
(48 & (1 << (0 + 5)) != 0).if { "foo".postln }

Quarks.gui

MIDIResponder

//'''''''''''''''''''''''''''''''''''


AppClock
s.boot
a = MTCClock.new
a.attach(Pbind(), 120, 240);

MIDIResponder.help


(
a.sched(5, {|tick, time, clock| ("3.5 beats later - relative to now"+tick+time+clock).postln; nil; })
)

Array.fill(8, 0)



PriorityQueue.new

a.nextTimeOnGrid 

a.schedAbs(300, {|tick, time, clock| ("300").postln; nil; })


f = ()
f[#[23, 23]] = 23
f[23] = 234
g = Pbind()
g.play(0)
g.stop(0)
Pattern

[2,3,4][0..1]
hmsf

nil.play()

f = {"foo".postln; 1}.fork
m = MTCClock.new(24)

AudioMulchClock

m.sched(m.fromFPS(1), {"test".postln; m.fromFPS(1)})
 
m.fromFPS(1)






