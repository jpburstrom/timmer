b = Buffer.read(s, "/Volumes/Mega/projects/timmer/render/to SC/granul-samples/arcodrone.wav")

//Grain stream with frequency from Pitch

(

{
    var snd, freq, hasFreq;
    snd = PlayBuf.ar(1, b, 2, loop:1);
    // snd = SoundIn.ar(0);
    # freq, hasFreq = Pitch.kr(Mix.new(snd), 220, 30, 1000).lag(10);
    freq = [freq, freq * 0.5];
    Splay.ar(GrainIn.ar(1, Impulse.ar(freq), freq.reciprocal * 0.75, snd, 0, q.buf.envs.grain.tri ), 0 )

}.play

)