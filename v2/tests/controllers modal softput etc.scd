MFdef.all.test = nil;
MFdef(\test, [
    \page1, { |x| "This is page 1: %".format(x.value).postln; },
    \page2, { |x| "This is page 2: %".format(x.value).postln; },
    \page3, { |x| "This is page 3: %".format(x.value).postln; },
    \page4, { |x| "This is page 4: %".format(x.value).postln; },
]).makeExclusiveModes(\pages, [\page1, \page2, \page3, \page4]);
e = EZSlider(nil, 300@30, "MFunc test", nil, MFdef(\test), 0.5);
MFdef(\test).mode = \page2;

(
//SoftPut -- borde inte behövas om man fixar midi feedback
var lastVal;
r = (amp:0.1);
e = EZSlider(nil, 300@30, "MFunc test", nil, { |x|
    r.softPut(\amp, x.value, lastVal: lastVal);
    lastVal = x.value;
    r.amp.postln;
}, 0.5);
)