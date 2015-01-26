t.clear;
t = Timber.new;
//Add patterns
t.add(Pbindef(\test1, \note, Pn(0,1), \dur, 0.1), \prob, 0.2);
t.add(Pbindef(\test2, \note, Pn(1,1), \dur, 0.1), \prob, 0.7);

//FEATURES
(
t.add(Pdef(\test));
x = t[0];
)

//add prewait:
x.prewait = 2.3
//add postwait:
x.postwait = 2.6

//When/until: a function run as routine, unhanging ~cond (a Condition)
//add 'when' condition:
x.when = { 2.wait; ~cond.unhang }
//add 'until' condition:
x.until = { 2.wait; ~cond.unhang }

//breaknote: break long notes on until
x.breaknote = true

//


//PLAYING
//10 iterations
t.asPattern(10).play;

//10 iterations, add an envir
t.asPattern(10, {~stretch = 1.rrand(10)}).play;

//10 iterations, add an envir + cleanup
t.asPattern(10, {~stretch = 1.rrand(10)}, {"CLEANUP".postln}).play;

//Stopping
t.asPattern(inf, {~stretch = 1.rrand(10)}, {"CLEANUP".postln}).play;
//oh no
t.suspendAll


//2 signals: \weights & \current
c = SimpleController(t);
c.put(\weights, { |obj| obj.calc_weights; obj.weights.postln })
c.put(\weights, nil)
c.put(\current, { |obj, what, bp| "crrbt".postln; bp.postln })


//Ui test.....

(
var w = Window.new;
var list = ListView();
var btn = Button();
var textArea = TextView();
var c = SimpleController(t);
var current = nil;

c.put(\weights, { |obj| list.items = t.sort({ arg a, b; a.prob > b.prob }).collect(_.thing.asString) });


w.layout_(HLayout(list, VLayout(btn, textArea)));
w.front;
)

t.sort { arg a, b; a.prob > b.prob }

//TODO:

- breaknote quantize (sätt den i p.breakquant)
- fixa t.suspendAll (pcs tempo_ not understood)
- add next
- add playSingle

test:
- prewait
- postwait
- when
- until
- breaknote

0.rrand(8)!2

(
t = Timber();
t.add(Pbind(\note, Pseq(0.rrand(8)!8)));
t[0].until = { currentEnvironment.postln; 2.5.wait; ~cond.unhang }
)
t[0].breaknote = true
t[0].postwait = 0
t[0].postfunc = nil

t.asPattern.play

t.suspendAll



keys:
\prefunc -- function to add before running
\when -- condition (function)
\prewait -- wait time before (float)
(thing)
\until -- condition
\postwait -- wait time after
\postfunc -- function to add after

\breaknote -- (bool) if true, use PatternConductor and clip notes when cond
\breakquant