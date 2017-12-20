~path = "/Users/johannes/projects/timmer-2016/kod/player/songs/04-20160915-1041.wav";
~path = "/Users/johannes/projects/timmer-2016/kod/render/160914_130613/08.wav"
(
~syn = Group();
~fx = Group.after(~syn);
)
e = SoundFile(~path).play((group: ~syn, amp:2));
e.stop

(
SynthDef(\verb, {
    var snd = In.ar(0, 2);
    snd = JPverb.ar(snd, \time.kr(1), \damp.kr(0), \size.kr(1), \ed.kr(0.707)) * \amp.kr(0.1);
    Out.ar(0, snd);
}).add;
)
x
x = Synth(\verb, [\amp, 0.3], ~fx);

x.set(\amp, -32.dbamp);
x.set(\amp, 0);

(
x.set(\time, 2);
x.set(\damp, 0.2);
x.set(\size, 1);
)
x.set
x.free
e

0.1.ampdb