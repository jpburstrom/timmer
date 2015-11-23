CVSyncMktl : CVSync {

	var <enabled=true;
	update { | changer, what ...moreArgs |	// called when CV changes
		switch( what,
			\synch, { if (enabled) { view.value = cv.input } }
		);
	}

	linkToView {
		view.addAction(this);
	}


	value { this.valueArray }

	valueArray { if (enabled) { "hello %,%".format(cv.input, view.value).postln; cv.input = view.value } }		// called when mktl changes

	enable { enabled = true }
	disable { enabled = false }

}

+ CV {
	connectMKtlElement { |mktl|
		^CVSyncMktl(this, mktl);
	}
}

+ MKtlElement {
	connectCV { |cv|
		^CVSyncMktl(cv, this);
	}
}