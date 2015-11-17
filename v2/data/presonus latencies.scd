(
{
    var snd = Decay.ar(Impulse.ar(0), 0.01);
    Out.ar(2, snd);
    [SoundIn.ar(7), snd];

}.plot(0.01)
)
Plotter

//48000
s.options.hardwareBufferSize = 64 //0.0067 = 322 samples:  194
s.options.hardwareBufferSize = 128 //0.0094 = 451 samples  195
s.options.hardwareBufferSize = 256 //0.0147 = 705 samples  193
s.options.hardwareBufferSize = 512 //0.0254 = 1219 samples 195
0.0040625 - 0.0033125
0.0040625 - 0.00075

0.0033125 //FAST LATENCY
0.000750 //36 samples
0.0040625 //totalt

(0.0040625 - (36/ 48000))



//96000
s.options.hardwareBufferSize = 64 //0.0056 = 537 samples:  409
s.options.hardwareBufferSize = 128 //0.0069 = 662 samples  406
s.options.hardwareBufferSize = 256 //0.0096 = 921 samples  409
s.options.hardwareBufferSize = 512 //0.0149 = 1430 samples 406

0.00425
0.003875 //FAST LATENCY
0.000375 //36 samples
0.00425 //totalt



(0.00425 - (36/ 96000))
((0.00375) + (15/ 96000))

x + y/96000 = 0.00425; x + y/48000 = 0.0040625


