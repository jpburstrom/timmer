(
~song = \tests;
"lib/init.scd".loadRelative
)

q.smpLoad('test-impulse')

q.buf['test-impulse'].play

q.smpLoad('mollackord')

q.buf['mollackord'][0].play

SynthDef(\test, {
    SinOsc.ar * 0.01})

Instr

SynthDef


