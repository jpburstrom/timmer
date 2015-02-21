//Init only


//TODO
//Noise

var ev = (
    //pitches: (28..28+39), //Från E
    pitches: 24.collect(_+36),
    basePath: "/Volumes/HD2/projects/timmer/kod/sc/live"

);
"live/init.scd".loadRelative[0].(ev);


//----------------TESTS--------------//

{
    //Solo slider
    z = EZSlider(nil, Rect(0, 0, 400, 50), \solo, [36, 93, \lin, 1], { |val|
        q.settings.pitches.do { |i|
            q.tree.synths[i.asSymbol].set(\out, q.bus[\test]);
        };
        q.tree.synths[val.value.asSymbol].set(\out, 0)
    });



    (
        Ndef(\fmtest, {
            //var in =  SinOsc.ar(100, SinOsc.ar(\freq.kr, 0, \amp.kr)) * 0.1;
            var fq = \freq.kr(200, lag:0.1);
            var in =  DelayC.ar(SinOsc.ar(100), 1, SinOsc.ar(fq, 0, \amp.kr(0.1, 1) * fq.reciprocal, fq.reciprocal * 10)) * 0.1;
            in // + SinOsc.ar(100, 0, 0.1)
        }).playN([0,1]);
    );
    Ndef(\fmtest).gui;
    Ndef(\fmtest).addSpec(\amp, [0,10]);

    Ndef(\fmtest).xset(\feedback, 10);


}
