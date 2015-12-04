Req.load([\params], { |params, cleanup|

	var
	vals, //tmp
	mfunc,
	cvsync,
	bcr,
	topRow,
	pageSwitchButtons,
	bottomEnc,
	lastRowCVs;

	bcr = MKtl(\bcr, "*bcr2000");
	//bcr.gui;
	bcr.elementAt(\kn).reset;
	//A way to access \kn elements by numerical index
	bottomEnc = bcr.elementAt(\kn).flat;


	lastRowCVs = #[morph, random, target, interpolationTime].collect(params.meta[_]) ++ params.meta.featureMap;

	//all CVs
	vals = ().make {
		~pr_1_1 = params.target ++ params.current ++ lastRowCVs;
		~pr_1_2 = params.eq24;
		~knUp = params.main;
	};

	cleanup.addFunc({
		//Clean up previously added MKtl->CV connections
		//vals keeps references to same CVs if we're not reloading that file
		//TODO: deal with that?
		vals.deepDo(2, { |cv|
			var deps = cv.dependants;
			deps.do { |x|
				if (x.class == CVSyncMktl) {
					x.remove;
				}
			}
		});
	});

	//
	cvsync = ().make {
		~kn1 = bottomEnc.collect({ |v, i|
			vals[\pr_1_1][i].connectMKtlElement(v);

		});
		~kn2 = bottomEnc.collect({ |v, i|
			vals[\pr_1_2][i].connectMKtlElement(v);

		});

		~knUp = bcr.elementAt(\knUp, \1).collect({ |v, i|
			vals[\knUp][i].connectMKtlElement(v);
		});
	};

	//----Top encoders-----------





	/*
	topRow = bcr.elementAt(\knUp, \1);
	topRow.action = { |elem|
		//Index is either 0 or 1 -- check with second row of button rows
		var rowIndex = bcr.elementAt(\bt, \2, elem.index).value.asInt;
		bcr.elementAt(\kn, rowIndex, elem.index).value = elem.value;

	}.inEnvir;

	//Top encoder buttons----------
	//Mute/set current to default
	bcr.elementAt(\tr, \1).action = { |elem|
		//Todo -- set default value? Mute/Solo?
		if (elem.value == 1) {
			topRow.at(elem.index).valueAction = 0;
		}
	}.inEnvir;

	{
		var other = [\2, \1];
		var kn = bcr.elementAt(\kn);
		bcr.elementAt(\bt).action = { |elem, row, grp|
			if (elem.value == 0) {
				elem.deviceValue = 127;
				//unset other row
				grp[other.indexOf(row.index)][elem.index].deviceValue = 0;
				topRow[elem.index].value = kn[row.index][elem.index].value;
			}
		}.inEnvir

	}.value;
	*/

	/*
	//----Bottom encoders (32)-------
	mfunc = MFunc();

	//---------first page: misc----------
	mfunc.add(\pr_1_1, { |elem, grp, row|
		var knobRows = [\1,\2];

		//If first two rows, set upper encoder value and set buttons to corresponding row

		if (knobRows.includes(grp.index)) {
			topRow.at(elem.index).value = elem.value;
			bcr.elementAt(\bt, grp.index, elem.index).value = 1;
			bcr.elementAt(\bt, 1 - knobRows.indexOf(grp.index), elem.index).value = 0;
		};


	}.inEnvir);

	//cvfunc.add(\pr_1_1, { |el|


	//--------------second page: eq gain---------
	mfunc.add(\pr_1_2, { |elem, grp, row|
		//vals[\pr_1_1][bottomEnc.indexOf(elem)] = elem.value;
	}.inEnvir);

	//--------Switch pages with two bottom-right buttons------
	mfunc.makeExclusiveModes(\pageswitch, [\pr_1_1, \pr_1_2]);
	*/

	{
		pageSwitchButtons = bcr.elementAt(\pr, \1).flat;
		bcr.elementAt(\pr, \1).action = { |elem, grp|
			var index = pageSwitchButtons.indexOf(elem);
			//mfunc.mode_(elem.name);
			if (index == 0) {
				cvsync[\kn1].do(_.enable);
				cvsync[\kn2].do(_.disable);
			} {
				cvsync[\kn1].do(_.disable);
				cvsync[\kn2].do(_.enable);
			};
			grp.at(1 - index).deviceValue = 0;
			elem.deviceValue = 127;
			//bcr.elementAt(\kn).disable;
			bottomEnc.do({ |x, i|
				x.value = vals[elem.name][i].input;
			});
			//bcr.elementAt(\kn).enable;
		}.inEnvir;
	}.value;

	//Sync with presets etc
	//bcr.elementAt(\kn).action = mfunc;
	bcr.elementAt(\pr, \1, \1).valueAction = 1;

	//Simulate key up
	// 8.do { |x| bcr.elementAt(\bt, \1, x).valueAction = 0 };

	bcr.sync;

	8.do { |x| bcr.elementAt(\bt, \2, x).valueAction = 0 };


	//Reload everything button
	bcr.elementAt(\pr, \2, \2).action = { |elem|

		if (elem.value == 1) {
			elem.value = 0;
			"../init.scd".loadRelative;
		}
	};

    bcr

});