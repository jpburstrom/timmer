q.bus.ctl_onsets.postln; q.bus.ctl_onsets.free


(
q.makeCtl(\onsets, \anaOnsets);
// q.makeCtl(\test, \anaPitch, { [\bustest, q.bus.ctl_onsets] });

)
Bus
(
var w = Window("Onsets");
var bang = BangButton().time_(0.025);
var views = 7.collect { View() };
var sliders = (), features, lastTime, delta, data;
w.setInnerExtent(375, 250);
features = ["long", "short"].collect { |x| ["StdDev", "Mean", "Integral"].collect { |y| (x ++ y).asSymbol } }.flatten;
([\delta] ++ features).do { |label, x|
    sliders[label.asSymbol] = EZSlider(views[x], nil, label, [0, 10].asSpec, labelWidth:120);
};
w.layout_(VLayout(
    HLayout(bang.button, nil),
    *views
));

w.front;

sliders.postln;
data = SensorData();

q.makeCtl(\onsets, \anaOnsets);

OSCdef(\ctl_onsets, { arg msg, time;

    bang.bang;

    msg.postln;

    delta = msg[3];

    data.addValue(delta);

    { sliders.delta.value = delta }.defer;

    features.do { |x|
        { sliders[x].value = data.perform(x) }.defer;

    };



    },'/tr', s.addr, nil, [{ arg id; q.ctl.onsets.nodeID == id}] );



)



OSCdef(\anaOnsets).add({ "hello".postln })

OSCdef(\ctl_onsets).remove({ "hello".postln })

OSCdef(\ctl_onsets).argTemplate.postcs

(
var w = Window("Onsets");
var bang = BangButton();
var views = 4.collect { View() };
w.setInnerExtent(375, 200);
EZSlider(views[0], nil, "Delta", [0, 20].asSpec, labelWidth:120);
EZSlider(views[1], nil, "Hello Hello hello", labelWidth:120);
w.layout_(VLayout(
    HLayout(bang.button, nil),
    *views
));
// w.rebuild;
w.front

)
Windo

DataNetwork
