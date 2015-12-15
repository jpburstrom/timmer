SynthDef(\hello, {
    var snd = SinOsc.ar(\freq.kr) * 0.1;
    Out.ar(\out.kr, snd);
}).add;

//----Testing CV
c = CV(\freq);
g = Group().register;
~slider = Slider()
~slider.front
c.connect(~slider);
c.value = 440
c.input = 0.5
c.action_ { |cv| cv.value.postln }
c.release

//Testing setControls
x = NodeProxy.audio(s, 1).prime(\hello)
x.group_(Group()); //Group is needed for .setControls
x.parentGroup_(g);
x.set(\freq, 200, \out, 0);
x.setControls([freq: c]);
x.play
x.gui
x.end

c.windex(\foo)


//----Testing CVPreset

c = 10.collect { CV() };
p = CVPreset()
p.items = c;
(
c.do (_.value = 0);
p.addPreset;
c.do (_.value = 1.0.rand); //Fill with random values
p.addPreset;
)
p.presetCV.value = 0; p.input
p.presetCV.value = 1; p.input

//Update current preset
p.presetCV.value = 1;
c.do (_.value = 1.0)
p.presets[p.presetCV.value] = c.collect(_.value)
p.presetCV.value = 0; p.input
p.presetCV.value = 1; p.input

//---Testing ProxyPreset
x = TaskProxy();
c.do { |v, i|x.set(i, v) }
p = ProxyPreset(x)

//----Testing homebrew preset interpolation
x = ();
c.do { |v, i| x[i] = v };
x.do(_.value = 0); y = x.collect(_.value);
x.do(_.value = 1); z = x.collect(_.value);
y.blend(z, 0.2).select { |v, k| [2,3,4].includes(k) }.do { |v, k|
    x[k].value = v;
}
x.collect(_.value)
//---As proto--
p = "../lib/protos/presets.scd".loadRelative[0];
p.items = x;
p.setItems(x); //The same
x.do(_.value = 0); p.addPreset(\zero);
x.do(_.value = 1); p.addPreset(\one);
p.current = \zero; p.target = \one;
p.morph(0.1)
x.collect(_.value);
p.morph(0.9, [2]);
x.collect(_.value)
