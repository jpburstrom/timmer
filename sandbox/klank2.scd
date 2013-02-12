(
~freqs = ( 'vibraphone': [ 1, 2.01, 3.99, 9.37 ], /*'marimba': [ 1, 3.99, 10.65, -2443 ], */ 'beats': [ 1, 1.004, 1.013, 2.377 ], 'clump': [ 1, 1.217, 1.475, 1.729 ], 'wood1': [ 1, 2.777, 7.378, 15.377 ], 'reso': [ 1, 2.777, 7.378, 15.377 ], /*'agogo': [ 1, 4.08, 6.669, -3725 ], 'fix2': [ 1, 4, -1320, -3960 ],*/ 'wood2': [ 1, 1.777, 2.378, 3.377 ] );
~resonances = ( 'vibraphone': [ 1.9999, 1.99982, 1.99984, 1.9998 ], 'marimba': [ 1.9992, 1.9988, 1.9988, 1.998 ], 'beats': [ 1.9998, 1.9998, 1.9998, 1.998 ], 'clump': [ 1.998, 1.998, 1.998, 1.998 ],   'wood1': [ 1.992, 1.988, 1.988, 1.98 ], 'reso': [ 1.99992, 1.99988, 1.99988, 1.9998 ], 'agogo': [ 1.998, 1.998, 1.998, 1.998 ], 'fix2': [ 1.9992, 1.998, 1.9988, 1.998 ], 'wood2': [ 1.992, 1.988, 1.988, 1.98 ] );
~amps = ( 'vibraphone': [ 0.05, 0.03, 0.03, 0.03 ], 'marimba': [ 0.08, 0.02, 0.02, 0.016 ], 'beats': [ 0.04, 0.01, 0.01, 0.008 ], 'clump': [ 0.06, 0.06, 0.06, 0.06 ],   'wood1': [ 0.08, 0.02, 0.02, 0.016 ], 'reso': [ 0.04, 0.01, 0.01, 0.008 ], 'agogo': [ 0.12, 0.1, 0.06, 0.04 ], 'fix2': [ 0.08, 0.02, 0.02, 0.016 ], 'wood2': [ 0.08, 0.02, 0.02, 0.016 ] );
)

(
// Vibraphone and wood2 is good
var insts = [ 'vibraphone', 'beats', 'clump', 'wood1', 'reso', 'wood2' ];
var inst = \wood2;
{
    var in = SoundIn.ar([0, 1]);
    var snd = LPF.ar(Mix(Klank.ar(`[~freqs[inst], ~amps[inst], [1.2]], in,  [56,58].midicps)), 5000);
    snd //+ (Decimator.ar(in, 48000, 13) * 0.1)
}.play;

)

~freqs[\vibraphone]

(
// Vibraphone and wood2 is good
var insts = [ 'vibraphone', 'beats', 'clump', 'wood1', 'reso', 'wood2' ];
var inst = \vibraphone;
{
    var in = SoundIn.ar([0, 1]);
    var snd = LPF.ar(Mix(Klank.ar(`[~freqs[inst], ~amps[inst], [1.5]], Impulse.ar(0),  [51].midicps)), 5000);
    snd //+ (Decimator.ar(in, 48000, 13) * 0.1)
}.play;

)

{SinOsc.ar(50, 0, 0.05)}.play