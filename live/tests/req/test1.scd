Req.load(nil, {
	33.rand;
});

//depending on the Req above
(
Req.load([\test1, '../reqtest2'], { |test1, reqtest2|
	[reqtest2,  test1];
}, key:\bob, reload:true);
);
