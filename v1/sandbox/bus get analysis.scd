b = Bus.control(s);
a = { Out.kr(b, LFNoise0.kr).range(0,1) }.play
a.free


(
{
    var v = -1;
    var tmp;
    loop {
        tmp = b.getSynchronous;
        if (tmp != v) {
            v = tmp;
            v.postln;
        };

        0.1.wait;
    }
}.fork
)


[].softPut

(`2).softPut

(test:2).softPut(2, 3, 1, spec:\unipolar)

- RemoveBadValues
MinItem / MaxItem
Schmidt
DetectSilence
SenseWorld

Hadron



fork { loop { 50.do{ b = b + (0.2.rand2); a.addValue( b ); g.updateVals; 0.1.wait;} } };
