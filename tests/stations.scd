(
~song1 = Buffer.read(s, "/Users/johannes/projects/timmer-2016/kod/player/songs/01-20160810-1044.wav");
~song2 = Buffer.read(s, "/Users/johannes/projects/timmer-2016/kod/player/songs/08-20160811-1345.wav");
)
(
Ndef(\radio, {
    var snd, snd1 = PlayBuf.ar(2, ~song1, BufRateScale.kr(~song1));
    var snd2 = PlayBuf.ar(2, ~song2, BufRateScale.kr(~song2));

    var fx1 = FreqShiftAA.ar(snd1, -600.rrand(-4000), LFNoise2.ar(1).range(0, 2pi));
    var fx2 = FreqShiftAA.ar(snd2, -600.rrand(-4000), LFNoise2.ar(1).range(0, 2pi));

    var control = K2A.ar(MouseX.kr(-1, 1));

    fx1 = RLPFD.ar(fx1, LFNoise2.ar(1).exprange(1440, 8880), 0.2, 0.3) * 8;

    snd1 = LinXFade2.ar(snd1, fx1, ((control * 2) + 1).min(1).poll);

    snd2 = LinXFade2.ar(snd2, fx2, ((control.neg * 2) + 1).max(-1).poll);


    snd = LinXFade2.ar(snd1, snd2, control);


    // LinXFade2.ar(snd1, FreqShiftAA.ar(snd1, -1000), K2A.ar(control.min(1));
    snd

}).play

)

//STATIONS

//Radio dial
//n number of songs
//n-1 number of transition effects
//divide radio dial into n areas, with sizes between 0.5/n and 2/n (or something)
//Each area has a playlist
//Playlists:
~n1 = (0..7).scramble; //Scramble when launching app. Re-scramble when songs have been played through
~n2 = ~n1.rotate(-1);
//and so forth

//All songs have same length
//Time is running continously
//Songs play through playlist
//Only two songs are playing at the same time

//Transition effects are also scrambled, and not tied to two specific songs

//We might have handclaps or similar
//Songs have metadata with transients/places to cut
//Synth is also a good thing, during transitions

//There is an auto button
//Some stations

//--GUI--
(
w = Window.new("Stations").layout_(VLayout());
x = UserView(w);
k = Knob(w).mode_(\vert).step_(0.0001);
~pos = 0;
k.action = { |v|
    v.postln;
    ~pos = v.value;
    x.refresh;
};
x.drawFunc = { |v|
    Pen.stringAtPoint("Things to do", Point((~pos * -10000) + 140, 0))
};
w.front

)