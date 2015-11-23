Req.load([\devices, \params], { |midi, params|

	midi.make {

		var vals, mfunc, cvsync, bcr, pageSwitchButtons;

		bcr = ~bcr = MKtl(\bcr, "*bcr2000");
		~bcr.gui;
		~bcr.elementAt(\kn).reset;
		~bottomEnc = ~bcr.elementAt(\kn).flat;

		params.postln;

		cvsync = ().make {
			~kn1 = ().make {
				~current = params.main.current.collect { |v, k| v.connectMKtlElement(bcr.elementAt(\kn, \1, k)) };
				~target = params.main.target.collect { |v, k| v.connectMKtlElement(bcr.elementAt(\kn, \1, k)) };
			};
			~kn2 = ();
			~bottomEnc.do { |k,i|
				~kn2[k.index] = params.eq24[k.index].connectMKtlElement(k);
			}
		};

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
		vals = (pr_1_1: 0!32, pr_1_2:0!32); //TODO: get preset values
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

			//TODO: set model values
			//This is a placeholder
			vals[\pr_1_1][~bottomEnc.indexOf(elem)] = elem.value;

		}.inEnvir);

		//cvfunc.add(\pr_1_1, { |el|


		//--------------second page: eq gain---------
		mfunc.add(\pr_1_2, { |elem, grp, row|



		}.inEnvir);

		//--------Switch pages with two bottom-right buttons------
		mfunc.makeExclusiveModes(\pageswitch, [\pr_1_1, \pr_1_2]);

		{
			pageSwitchButtons = ~bcr.elementAt(\pr, \1).flat;
			~bcr.elementAt(\pr, \1).action = { |elem, grp|
				mfunc.mode_(elem.name);
				grp.at(1 - pageSwitchButtons.indexOf(elem)).deviceValue = 0;
				elem.deviceValue = 127;
				//~bcr.elementAt(\kn).disable;
				~bcr.elementAt(\kn).flat.do({ |x, i|
					x.value = vals[elem.name][i];
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