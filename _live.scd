//Init only


//TODO
//Noise

var ev = (
    pitches: (36..93)

);
"live/init.scd".loadRelative[0].(ev);


(
Ndef(\fmtest, {
    //var in =  SinOsc.ar(100, SinOsc.ar(\freq.kr, 0, \amp.kr)) * 0.1;
    var fq = \freq.kr(200, lag:0.1);
    var in =  DelayC.ar(SinOsc.ar(100), 1, SinOsc.ar(fq, 0, \amp.kr(0.1, 1) * fq.reciprocal, fq.reciprocal * 10)) * 0.1;
    in // + SinOsc.ar(100, 0, 0.1)
}).playN([0,1]);
)
Ndef(\fmtest).gui
Ndef(\fmtest).addSpec(\amp, [0,10])

Ndef(\fmtest).xset(\feedback, 10)

200.reciprocal
s.hasShmInterface