(
~p.addPrep( \room1, e {
	var bufs;
	bufs = (0..1).collect( { |num|
		var channel, bufsize, buf;
		channel = Buffer.readChannel(s, 
			~p.s.currentPath ++ "/../../../impulses/room1.wav", channels:[num]);
		s.sync;
		bufsize = PartConv.calcBufSize(2048, channel);
		buf = Buffer.alloc(s, bufsize, 1);
		buf.preparePartConv(channel, 2048);
		s.sync;
		channel.free;
		buf	
	});
	~p.addBuffer(\room1_bufL, bufs[0]);
	~p.addBuffer(\room1_bufR, bufs[1]);
});
)


