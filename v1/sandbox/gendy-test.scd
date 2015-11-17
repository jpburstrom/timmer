b = Buffer.read(s, "/Volumes/Mega/projects/timmer/samples/banks/hits/hits-55.wav")
b.numFrames
(
{Pan2.ar(BufRd.ar(2, c, Gendy1.ar(2, 5, 0.01, 0.01, 50, 80, 1, 1, 24).range(0,c.numFrames).poll, 0.0))}.play
)

c = Buffer.read(s, "/Volumes/Mega/projects/timmer/samples/banks/part4-huff/part4-01-Stall-110520_1412-001 20111216-152341 render 011.wav")

(
{
    var snd = Gendy1.ar(2, 4, 0.1, 0.9, 200, 300, 0.5, 0.5, MouseX.kr(1,13)) * 0.01;
    snd;
    // OpLPF.ar(snd, 240);
}.play

)