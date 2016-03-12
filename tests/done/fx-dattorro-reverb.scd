//Trying to make a reverb
//probably everything is wrong

~buf = Buffer.read(s, "/tmp/test.wav")

(

var log001 = log(0.001);
var mkAllpass1 = { |snd, ms, coef|
    var deltime = ms * 0.001;
    var decaytime = deltime.neg * log001 / log( coef );
    var attsnd = snd * coef;
    //Originally this was summed with (snd * coef), but sounds better without?
    //But then, early reflections not so much
    //Last subtraction is needed to remove the first attenuated impulse from AllpassN
    //http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/AllpassN-vs-AllpassC-impulse-response-bug-td7623942.html
    attsnd + AllpassN.ar(attsnd, deltime, deltime, decaytime) - (snd * coef.pow(2)) ;
};
//This one is different -- delaytime LFO, and has a positive feedback coef
var mkAllpass2 = { |snd, ms, coef, exc|
    var deltime = ms * 0.001;
    var decaytime = deltime * log001 / log( coef );
    var attsnd = snd * coef;
    // var phase = pi*0.5; //Just for testing
    //Why is (v) this coef.neg and not coef?
    //Maybe add this?
    attsnd.neg +
    AllpassN.ar(attsnd, 0.1, SinOsc.ar(1, 0, exc * 0.001, deltime).min(0.1), decaytime) - (snd.neg * coef.pow(2));
};

Ndef(\test_dattorro).addSpec(
    \in_diff1, [0, 0.99],
    \in_diff2, [0, 0.99],
    \decay_diff1, [0, 0.99],
    \decay_diff2, [0, 0.99],
    \excursion, \unipolar,
    \bandwidth, [20, 24000, \exp],
    \damping, [20, 24000, \exp],
    \predelay, [0, 100, 4],
    \decay, [0, 0.99]

);

Ndef(\test_dattorro, { arg decay_diff2=0.5;
    var orig, snd = Impulse.ar(0.25);
    var out = DC.ar.dup;
    var local, tmp = LocalIn.ar(2);
    var test;
    var x;
    //Predelay
    snd = PlayBuf.ar(2, ~buf, loop:1).sum;
    orig = snd;
    snd = DelayC.ar(snd, 1, \predelay.kr(0) * 0.001);
    //Bandwidth
    snd = OpLPF.ar(snd, \bandwidth.kr(22000));
    //Input diffusion
    snd = mkAllpass1.value(snd, 4.77134, \in_diff1.kr(0.75));
    snd = mkAllpass1.value(snd, 3.5953, \in_diff1.kr);
    snd = mkAllpass1.value(snd, 12.7348, \in_diff2.kr(0.625));
    snd = mkAllpass1.value(snd, 9.30748, \in_diff2.kr);

    //59_63 & 33_39
    [0.0670676, 0.0898155].do { arg time, i;
        out[i] = DelayC.ar(tmp[i], time, time);
    };
    //59_63 & 33_39 reversed
    [0.0358187, 0.00406572].do { arg time, i;
        out[i] = out[i] + DelayC.ar(tmp[1-i], time, time);
    };

    //Delay local in
    //TODO: subtract ControlDur
    local = [snd + DelayC.ar(tmp[0], 0.10628, 0.10628, \decay.kr(0.5)),
        snd + DelayC.ar(tmp[1], 0.124996, 0.124996, \decay.kr)];

    //Decay diffusion 1
    local[0] = mkAllpass2.(local[0], 22.599, \decay_diff1.kr(0.7), \excursion.kr(0.53761));
    local[1] = mkAllpass2.(local[1], 30.5097, \decay_diff1.kr, \excursion.kr);
    //24_30 & 48_54
    [0.066866, 0.0709317].do { arg time, i;
        out[i] = out[i] - DelayC.ar(local[i], time, time);
    };
    //48_54, reversed
    [0.00893787, 0.0999294].do { arg time, i;
        out[0] = out[0] + DelayC.ar(local[1], time, time);
    };
    //24_30, reversed
    [0.0118612, 0.121871].do { arg time, i;
        out[1] = out[1] + DelayC.ar(local[0], time, time);
    };

    //Delay
    local[0] = DelayC.ar(local[0], 0.149625, 0.149625);
    local[1] = DelayC.ar(local[1], 0.141695, 0.141695);

    //Damping & decay
    local = OpLPF.ar(local, \damping.kr(20000), \decay.kr);

    //Decay diffusion 2
    local[0] = mkAllpass1.(local[0], 60.4818, decay_diff2); //31_33
    local[1] = mkAllpass1.(local[1], 89.2443, decay_diff2); //55_59

    //31_33 & 55_59
    //This makes output from allpass louder (undo last decay) and un-inverted, but we skip that for now
    x = 1 / (1 - decay_diff2.pow(2));
    // x = 1;
    [0.00628339, 0.0112563].do { arg time, i;
        out[i] = out[i] - DelayC.ar(local[i] * x, time, time);
    };
    //31_33 & 55_59 reversed
    [0.00642787, 0.0412621].do { arg time, i;
        out[i] = out[i] - DelayC.ar(local[1 - i] * x, time, time);
    };

    LocalOut.ar(local.reverse);

    //Output

    orig + (out * 1);


}).play
)
Ndef(\test_dattorro).gui