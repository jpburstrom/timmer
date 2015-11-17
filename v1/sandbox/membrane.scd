SpearFile

s = SpearWeightedPartials.fromFiles("/Volumes/Mega/projects/timmer/render/analyse/klang1.txt")
b = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/analyse/klang1.wav")
s.getFreqsForTimeRange(5, 6)
c = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/part1-samples/Grips-20110825-012.wav")
s.partials.size
d = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/part1-samples/nr/Greppbrada-20110825-010-nr.wav")
d.play
RBE_SDIF_File

Quarks.gui

MembraneCircle

s = Server.default
d.bufNum
c.play
(
{
    a.free;
    0.2.wait;
    a = { arg trig;
        var excitation = EnvGen.kr(Env.perc,
                                        MouseButton.kr(0, 1, 0),
                                         timeScale: 0.1, doneAction: 0
                                    ) * PinkNoise.ar(0.4);

          var tension = MouseX.kr(0.01, 0.1);
          var loss = MouseY.kr(0.999999, 0.999, 1);
        excitation = HPF.ar(PlayBuf.ar(2, c, 2, trig), 5);
          Mix(MembraneHexagon.ar(excitation, [0.04, 0.07, 0.02, 0.10, 0.005] * 0.82, 0.9999, 0.2) + excitation);
    }.play;
}.fork
)