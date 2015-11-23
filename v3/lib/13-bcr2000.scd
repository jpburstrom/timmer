Req.load([\devices, \params], { |midi, params|

	midi.make {

		var
        vals, //tmp
        mfunc,
        cvsync,
        bcr,
        pageSwitchButtons,
        bottomEnc;

		bcr = ~bcr = MKtl(\bcr, "*bcr2000");
		//~bcr.gui;
		~bcr.elementAt(\kn).reset;
        //A way to access \kn elements by numerical index
		bottomEnc = ~bcr.elementAt(\kn).flat;

        //all CVs
        vals = ().make {
            ~pr_1_1 = (params.main.current ++ params.main.target ++ (CV()!8));
           ~pr_1_2 = params.eq24;
        };

        //Clean up previously added MKtl->CV connections
        //vals keeps references to same CVs if we're not reloading that file
        //so ok, we need to deal with that
        //But maybe we'll just put a ~bcr.reset at top, does that work?
        //OTOH would be good if Req.load had a nice way to deal with unloading resources
        //
        vals.deepDo(2, { |cv|
            var deps = cv.dependants;
            deps.do { |x|
                if (x.class == CVSyncMktl) {
                    x.remove;
                }
            }
        });


        //
        cvsync = ().make {
			~kn1 = params.main.current.collect({ |v, i|
                   v.connectMKtlElement(bcr.elementAt(\kn, \1, i));
            })
            ++
			params.main.target.collect({ |v, i|
                v.connectMKtlElement(bcr.elementAt(\kn, \2, i));
            });
            //TODO: add third row

            ~kn2 = params.eq24.collect { |v,i| v.connectMKtlElement(bottomEnc[i]) };
		};

        a = vals.postln;
		~cvsync = cvsync;

		//----Top encoders-----------
		~topRow = ~bcr.elementAt(\knUp, \1);
		~topRow.action = { |elem|
			//Index is either 0 or 1 -- check with second row of button rows
			var rowIndex = ~bcr.elementAt(\bt, \2, elem.index).value.asInt;
			~bcr.elementAt(\kn, rowIndex, elem.index).value = elem.value;

		}.inEnvir;

		//Top encoder buttons----------
		//Mute/set current to default
		~bcr.elementAt(\tr, \1).action = { |elem|
			//Todo -- set default value? Mute/Solo?
			if (elem.value == 1) {
				~topRow.at(elem.index).valueAction = 0;
			}
		}.inEnvir;



		//----Bottom encoders (32)-------
		mfunc = MFunc();

		//---------first page: misc----------
		mfunc.add(\pr_1_1, { |elem, grp, row|
			var knobRows = [\1,\2];

			//If first two rows, set upper encoder value and set buttons to corresponding row
			if (knobRows.includes(grp.index)) {
				~topRow.at(elem.index).value = elem.value;
				~bcr.elementAt(\bt, grp.index, elem.index).valueAction=1;
				~bcr.elementAt(\bt, 1 - knobRows.indexOf(grp.index), elem.index).valueAction=0;
			};

		}.inEnvir);

		//cvfunc.add(\pr_1_1, { |el|


		//--------------second page: eq gain---------
		mfunc.add(\pr_1_2, { |elem, grp, row|
            //vals[\pr_1_1][bottomEnc.indexOf(elem)] = elem.value;
		}.inEnvir);

		//--------Switch pages with two bottom-right buttons------
		mfunc.makeExclusiveModes(\pageswitch, [\pr_1_1, \pr_1_2]);

		{
			pageSwitchButtons = ~bcr.elementAt(\pr, \1).flat;
			~bcr.elementAt(\pr, \1).action = { |elem, grp|
                var index = pageSwitchButtons.indexOf(elem);
				mfunc.mode_(elem.name);
                if (index == 0) {
                    "enable kn1".postln;
                    cvsync[\kn1].do(_.enable);
                    cvsync[\kn2].do(_.disable);
                } {
                    "enable kn2".postln;
                    cvsync[\kn1].do(_.disable);
                    cvsync[\kn2].do(_.enable);
                };
                grp.at(1 - index).deviceValue = 0;
                elem.deviceValue = 127;
				//~bcr.elementAt(\kn).disable;
				bottomEnc.do({ |x, i|
					x.value = vals[elem.name][i].input;
				});
				//~bcr.elementAt(\kn).enable;
			}.inEnvir;
		}.value;

		//Sync with presets etc
		~bcr.elementAt(\kn).action = mfunc;
		~bcr.elementAt(\pr, \1, \1).valueAction = 1;
		~bcr.sync;

	};


});