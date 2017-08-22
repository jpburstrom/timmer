//Sets random seed for server
//TODO: use RandID
SynthDef(\setRandSeed, { |seed|
    var trig = Impulse.kr(0);
    RandSeed.kr(trig, seed);
    FreeSelf.kr(trig);
}).add;

