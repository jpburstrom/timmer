//Various helper functions/utilities
Proto({
	~connectCVtoMKtl { |cv, mktl|
		mktl.addAction { cv.input = mktl.value };
		cv.action = { mktl.value = cv.input };
	}
});