Req.load(#[params], { |params, cleanup|

	var px, clist = List();

	cleanup.addFunc {
		p.do(_.adieu);
		px.end(0).remove;
	};

	px = ProxySpace(s, \timmer);

	q.px = px;

	px
});

