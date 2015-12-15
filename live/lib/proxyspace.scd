Req.load(#[params], { |params, cleanup|

	var px=(), clist = List();

	cleanup.addFunc {
		p.do(_.adieu);
		px.proxyspace.end(0).remove;
	};

	px.proxyspace = ProxySpace(s, \timmer);

	/*px.input = Group(px.proxyspace.group).register(true);
	px.analysis = Group.after(px.input).register(true);
	px.synths = Group.after(px.analysis).register(true);
*/
	q.px = px;

	px
});

