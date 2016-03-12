
(

var h, w = Window();
~things = ~things ? ();

w.layout_(h = GridLayout());
30.do { |index|
	var col = index % 8;
	var row = index.div(8);
	var layout = View().layout_(VLayout());
	var btn = Button(layout);
	var dropdown = PopUpMenu(layout).items = 30.collect(_.asString);
	~things[index] = ~things[index] ? 0;
	dropdown.action = {
		~things[index] = dropdown.value;
	};
	dropdown.value = ~things[index];
	btn.states_([["Segment %".format(index)]]).action_({
		q.player.playSegment(index);
	});
	h.add(layout, row, col);
	index.postln;
};
w.front
)

q.player.prep
q.player.playSegment(91)

StringArray

~things.collectAs(_.value, Array)

~order = 30.collect { |x| ~things[x] }

