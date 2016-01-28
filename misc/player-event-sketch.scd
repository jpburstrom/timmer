//list of times per label
~lookup = (label1: [1,2,3], label2: [1,4])
//Order of keys to be executed every tick
~actionOrder = [\onset, \label1, \label2];
//List of events
~score = [(),()...]
//Current position (in ~tickLabel units)
~pos = 0
//Actions
~actions = (label1: (start: { |self, ev| }, stop: {}));



}

Pspawner

Spawner

(play: #{ |server| server.sync } ).play

Event

Event.default[\eventTypes][\sync] = #{ | server | server.sync };

(
Pproto({
    ~bufnum = (type: \allocRead, path: p.songPath).yield;
    thisThread.beats.debug("before sync");

    //(type:\sync).yield ;
    thisThread.beats.debug("asd sync");

},
Pbind(\dur, Pn(1, 1)), {"hello".postln }).play
)


Event.addEventType(\sync, { (~server ?? { Server.default }).sync });
2.playAndDelta

EventStreamPlayer