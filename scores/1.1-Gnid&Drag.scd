/*
Solobakgrund.
*/
//For NRT
//~filename = thisProcess.argv[0] ?? { "/tmp/test.wav" };
~p = nil;
Server.default = Server.local;
(
	s.waitForBoot {
		~p ?? {
			PdefAllGui.new;
			~p = Proto();
			~p.name = "inlandet";
			~p.s = ();
			~p.d = ();
			~p.s.currentPath = thisProcess.nowExecutingPath.dirname.dirname;
			(~p.s.currentPath +/+ "scores/lib/*").loadPaths;


			~p.addPrep( \gnid1, e {
				~p.readBuffer(\gnid, "Gnid-20110825-002-nr.wav");

				Pdef.defaultQuant = 0;
				//do stuff
				~pw = ~p.wrapper.copy;
			}, 1);

			//Add some synths
			~p.addPrep(\gnid2, e {
				~p.playSynth(\delay, \bitCrushDelay,
					[\in, ~p.s.bus.delay], s, \addToTail);
			}, 0); //A priority of 0 makes it restart on cmd-period.
		};o

		~p.run(
			e {
			~pw !? { ~pw.dropValue = 1 };
			~pw.pattern = Pbindf(~p.d.durations) <>
				Pbindf(Pdef(\impulseStringChords), \attack, 0, \db, -33, \softness, 0);

			//Add routines
			~pw.onCounter = ();
			~pw.onFirst = {
			};
			~pw.onEvery = e { |ev|
			};
			//Pdef(\main, ~pw).play;
		});
	}
);

