//Simple UI for grouping q.player segments into classes

(

var h, w = Window();
~things
~things = ~things ? ();

w.layout_(h = GridLayout());
31.do { |index|
	var col = index % 8;
	var row = index.div(8);
	var layout = View().layout_(VLayout());
	var btn = Button(layout);
	var dropdown = PopUpMenu(layout).items = 30.collect(_.asString);
	~things[index] = ~things[index] ? index;
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
~things.size
~things = ()
q.player.prep
q.player.playSegment(91)

StringArray

~things.collectAs(_.value, Array)


~order = ~things.size.collect { |x| ~things[x] }
~groups = ();
~order.do { |g, i|
    ~groups[g] = ~groups[g].add(i);
    ~groups.postln;
};
~groups.size.collect{ |x| ~groups[x]}.postcs
~order
~groups.keys