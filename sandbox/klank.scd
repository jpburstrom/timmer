~freqs = ( 'vibraphone': [ 1, 2.01, 3.9, 14.37 ], /*'marimba': [ 1, 3.99, 10.65, -2443 ], */ 'beats': [ 1, 1.004, 1.013, 2.377 ], 'clump': [ 1, 1.217, 1.475, 1.729 ], 'wood1': [ 1, 2.777, 7.378, 15.377 ], 'reso': [ 1, 2.777, 7.378, 15.377 ], /*'agogo': [ 1, 4.08, 6.669, -3725 ], 'fix2': [ 1, 4, -1320, -3960 ],*/ 'wood2': [ 1, 1.777, 2.378, 3.377 ] );
~resonances = ( 'vibraphone': [ 1.9999, 1.99982, 1.99984, 1.9998 ], 'marimba': [ 1.9992, 1.9988, 1.9988, 1.998 ], 'beats': [ 1.9998, 1.9998, 1.9998, 1.998 ], 'clump': [ 1.998, 1.998, 1.998, 1.998 ],   'wood1': [ 1.992, 1.988, 1.988, 1.98 ], 'reso': [ 1.99992, 1.99988, 1.99988, 1.9998 ], 'agogo': [ 1.998, 1.998, 1.998, 1.998 ], 'fix2': [ 1.9992, 1.998, 1.9988, 1.998 ], 'wood2': [ 1.992, 1.988, 1.988, 1.98 ] );
~amps = ( 'vibraphone': [ 0.05, 0.03, 0.03, 0.03 ], 'marimba': [ 0.08, 0.02, 0.02, 0.016 ], 'beats': [ 0.04, 0.01, 0.01, 0.008 ], 'clump': [ 0.06, 0.06, 0.06, 0.06 ],   'wood1': [ 0.08, 0.02, 0.02, 0.016 ], 'reso': [ 0.04, 0.01, 0.01, 0.008 ], 'agogo': [ 0.12, 0.1, 0.06, 0.04 ], 'fix2': [ 0.08, 0.02, 0.02, 0.016 ], 'wood2': [ 0.08, 0.02, 0.02, 0.016 ] )

~freqs.collect({ |x, y|
    (freq: ~freqs[y], amp: ~amps[y], res: ~resonances[y])
}).ccopy

/*jjjj
//Also good:
frequencies= {1, 2.7, 5.2, 8.4, 12.2}
amplitudes={0.1, 0.3, 0.3, 0.2, 0.1}
resonances={4, 0.5, 0.5, 0.3, 0.3}
*/

(
~buffers = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/hits/hits*.wav", s);
~buffers2 = SoundFile.collectIntoBuffers("/Volumes/Mega/projects/timmer/samples/banks/part4-huff/*.wav", s)

)

(
var buf = ~buffers.choose;
// Vibraphone and wood2 is good
var insts = [ 'vibraphone', 'beats', 'clump', 'wood1', 'reso', 'wood2' ];

{
    var inst, note;
    31 .do { |i|
        inst = insts.choose;
        inst = \wood2;
        note = (15.collect { arg i; [0,2] + (i * 5) }.flatten + 30)[i % 30];
        // ~amps[inst].postln;
        buf = ~buffers.choose;
        { var snd = 0.3 * Klank.ar(`[~freqs[inst], ~amps[inst], 0.04.rrand(0.2) * ~resonances[inst]], PlayBuf.ar(2, buf),  note.midicps);
            DetectSilence.ar(snd, 0.00001, doneAction:2);
            snd
        }.play;
        ([0.1, 1].choose).wait
    }
}.fork

)
