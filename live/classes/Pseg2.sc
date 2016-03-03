
//Like Pseg, but counting number of events instead of time
Pseg2 : Pstep {
	var <>curves;

	*new { arg levels, durs = 1, curves = \lin,  repeats = 1 ;
		^super.new(levels, durs, repeats).curves_(curves)
	}
	embedInStream { arg inval;
		var valStream, durStream, curveStream, startVal, val, dur, curve;
		var env, i;
		repeats.value(inval).do {
			valStream = list.asStream;
			durStream = durs.asStream;
			curveStream = curves.asStream;
			val = valStream.next(inval) ?? {^inval};
            i = 0;
            while {
				startVal = val;
				val = valStream.next(inval);
				dur = durStream.next(inval);
				curve = curveStream.next(inval);

				val.notNil and: { dur.notNil and: { curve.notNil } }
			} {
				if (startVal.isArray) {
					env = [startVal,val, dur, curve].flop.collect { | args |
						Env([args[0], args[1]], [args[2].floor], args[3]) };
					while { i < env.duration } {

						inval = yield(env.collect{ | e | e.at(i)});
                        i = i + 1;
					}
				} {
                    env = Env([startVal, val], [dur.floor], curve);
					while { i < env.duration } {
						inval = yield(env.at(i));
                        i = i + 1;
					};
                    i = 0;

				}
			}
		}
	}
	storeArgs {
		^[list, durs, curves, repeats]
	}
}