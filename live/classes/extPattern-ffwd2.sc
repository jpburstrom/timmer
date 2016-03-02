PFastForward2 : FilterPattern {
	var <>items, <>maxdur;
	*new { arg pattern, items;
		^super.newCopyArgs(pattern, items)
	}
	storeArgs { ^[pattern, items] }
	embedInStream { arg event, cleanup;
		var item, delta, inevent, first;
		var stream = pattern.asStream;

		cleanup ?? { cleanup = EventStreamCleanup.new };

        stream.nextN(items, event);

        loop {

            inevent = stream.next(event) ?? { ^event };
			cleanup.update(inevent);

			event = inevent.yield;

		}
	}
}

+Pattern {

    ffwd2 { |items|
        ^PFastForward2(this, items);
    }

}
