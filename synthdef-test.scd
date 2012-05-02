(
~sample = Sample.new;
~sample.gui.loadDialog
~sample.play
)

Instr.dir = "Instr/".resolveRelative

p.gui
[~sample]


// Make a patch. Leave all args that you want to control later undefined, and it seems to work better.
p = Patch("timmer.grain1", [~sample])
p.play
a = p.asSynthDef
a.controlNames
a.play
//
//Use some  
Pbind(*[instrument: a.name, legato:10, dur: Pbrown(0.1,0.2), vol: Pwhite(0.0,6.0), pos: Pwhite(0, ~sample.size)]).play

~sample.buffer
Pwhite(0.0,6.0).asStream.nextN(4)

MoltenMaster

Patterns

Ppar([p, BP(\asd)]).play

Pbind(p, q).play

BP(\qwe).play