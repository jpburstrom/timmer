CVSyncMktl : CVSync {

	var <enabled=true;
	update { | changer, what ...moreArgs |	// called when CV changes
		switch( what,
			\synch, { if (enabled) {
				view.value = cv.input
			} }
		);
	}

	linkToView {
		view.addAction(this);
	}


	value { this.valueArray }

	valueArray { if (enabled) {
		enabled = false;
		cv.input = view.value;
		enabled = true;

	} }		// called when mktl changes

	enable { enabled = true }
	disable { enabled = false }

    remove {
        cv.removeDependant(this);
        view.removeAction(this);
    }

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