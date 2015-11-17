/*//---Snickarglädje
SynthDef(\klanky, { |freq=440, sustain=1, bufnum=0, amp=0.6|
    var snd = PlayBuf.ar(2, bufnum) * EnvGen.ar(Env.perc(0, sustain, amp, 0), doneAction:2);
    snd = (Klank.ar(`[[1, 1.97,3.34,5], [2,2,4,0.2].normalizeSum, [0.3,1.2,0.1,1.3]], snd, freq, 0, sustain) * 0.2);
    // snd = snd * EnvGen.kr(Env([0,1,1], [0, sustain]), doneAction:2);
    Out.ar(0, snd);
}).add;
*/

var klank4Variants = (
    'Clump': (
        'kfreq': #[ 1, 1.217, 1.475, 1.729 ] ,
        'kamp': #[ 0.06, 0.06, 0.06, 0.06 ],
        'kres': #[ 1.0, 1.0, 1.0, 1.0 ],
    ),
    'Beats': (
        'kfreq': #[ 1, 1.004, 1.013, 2.377 ] ,
        'kamp': #[ 0.04, 0.01, 0.01, 0.008 ],
        'kres': #[ 1.0, 1.0, 1.0, 0.999099909991 ],
    ),
    'Reso': (
        'kfreq': #[ 1, 2.777, 7.378, 15.377 ],
        'kamp': #[ 0.04, 0.01, 0.01, 0.008 ],
        'kres': #[ 1.0, 0.99997999919997, 0.99997999919997, 0.9999399975999 ],
    ),
    'Snickargladje': (
        'kfreq': #[ 1, 1.97, 3.34, 5 ],
        'kamp': #[ 0.0487, 0.0487, 0.0975, 0.0048 ],
        'kres': #[ 0.23076923076923, 0.92307692307692, 0.076923076923077, 1.0 ],
    ),
    'Wood1': (
        'kfreq': #[ 1, 2.777, 7.378, 15.377 ],
        'kamp': #[ 0.08, 0.02, 0.02, 0.016 ],
        'kres': #[ 1.0, 0.99799196787149, 0.99799196787149, 0.99397590361446 ],
    ),
    'Vibraphone': (
        'kfreq': #[ 1, 2.01, 3.9, 14.37 ] ,
        'kamp': #[ 0.05, 0.03, 0.03, 0.03 ],
        'kres': #[ 1.0, 0.9999599979999, 0.99996999849993, 0.99994999749988 ],
    ),
    'Wood2': (
        'kfreq': #[ 1, 1.777, 2.378, 3.377 ],
        'kamp': #[ 0.08, 0.02, 0.02, 0.016 ],
        'kres': #[ 1.0, 0.99799196787149, 0.99799196787149, 0.99397590361446 ],
    )
);

klank4Variants.keysValuesDo { arg name, ev;
    name = ("bufKlank4" ++ name).asSymbol;
    q.makeDef(\synth, name,
        {
            arg freq = 440, sustain=1, attack=0, curve= -4, bufnum=0, bufRate = 1,
            preamp = 0.2,
            triggeramp = 0.1,
            hpf = 100;




            var snd, in = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * bufRate) * EnvGen.ar(Env.perc(attack, sustain - attack, curve), doneAction:2);
            snd = HPF.ar(in, hpf);
            snd = EnvGen.kr(Env.linen(0, sustain - 0.02, 0.02), 1, preamp, doneAction:2)
            * Klank.ar(`[NamedControl.ir(\kfreq, ev.kfreq),
                NamedControl.ir(\kamp, ev.kamp * 25),
                NamedControl.ir(\kres, ev.kres)], snd, freq, 0, sustain * 0.6); //0.6 = by ear
            snd + (in * triggeramp) //.softclip

        }
    )
}


/*
q.buf.at('banks/hits')[0].normalize
Synth("bufKlank4Snickargladje", [\sustain, 2, \hpf, 200, \freq, 50, \bufnum, q.buf.at('banks/hits')[0]])

(
5.do {

Pmul(\dur, Pseq([1, 2/3], inf).stutter(Pseq([6, 9], inf)), Pbind(\instrument, "bufKlank4Vibraphone",
\bufnum, Pfunc({q.buf.at('banks/hits').choose}),
\triggeramp, 0, \bufRate, Pseries(step:0.02).fold(0.8,1.2), \freq, 100.rrand(1000) + Prand([50, 100, [50, 240]], inf), \dur, 0.2, \legato, 2, \width, Pwhite(0, 0.5), \hpf, 200, \db, -24)).play

}
)

*/
