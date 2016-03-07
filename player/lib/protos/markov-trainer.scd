//Automatic manual markov maker
//Audition phrase transitions and tell me how they rock
Proto({

	//Format: key->[[other, other, other], [prob, prob, prob]]
    ~chain = nil; //Don't initialize yet

	//Connect to a player
	~connect = { |player|
		~player = player;
	};

	~setBounds = { |start=0, end|
		~start = start;
		~end = end ?? { ~player.data[~player.tickLabel].size - 1 };
        [start, end]
    };

    ~initChain = {
        ~chain = ~player.readDataFile(~getFilename.(), { |writeFunc|
            ~chain = ();
            (~start..~end).do({ |k|
                ~chain[k] = List[List(), List()];
            });
            writeFunc.(~chain);
        }.inEnvir);

		currentEnvironment;
	};

    ~getFilename = {
        "markov-%-%".format(~start, ~end)
    };

    ~train = {
		var order = (~start..~end);
		var toChoose;
		var continue = true;
		var cond = Condition();
        var dirty = false;

		var tmpfile = PathName.tmp +/+ "mktrain%.archive".format(Date.getDate.stamp);

        var writeFile = {
            ~player.writeDataFile(~chain, ~getFilename.(), { |writeFunc|
                //After auditioning, maybe do it again?
                ModalDialog({ |p|
                    CXLabel(p, "Ok, time to save. File exists. Write anyway?", 300);
                }, { |p|
                    writeFunc.();
                    cond.unhang;
                }, "File exists",
                {
                    cond.unhang;
                });
            });
            //Hang until modal is done
            cond.hang

        };

        if (~chain.isNil) {
            ~initChain.value;
        };

        {

			"Writing temporary backup data to %".format(tmpfile).inform;

            //If we've chosen not to continue, or if all ~chain slots are filled,
            //stop the operation.
            while { continue and: { ~chain.collectAs({ |x| x[0].size },
                    Array).selectIndices(_ != (order.size - 1)).isEmpty.not} } {

                order = order.scramble; //Randomize order for fun
				toChoose = order.rotate(order.size - 1);

                order.scramble.do { |from, index|
					var to;
					index = index % toChoose.size;
					if (~chain[from][0].size < (order.size - 1)) {
						while { ~chain[from][0].includes(toChoose[index]) or: { from == toChoose[index] } } {
							index = (index + 1) % toChoose.size;
						};
						to = toChoose.remove(toChoose[index]);
						~player.setIterator(Pseq([from, to]));
						~player.play;
						~displaySlider.(from, to, { |val|
							~chain[from][0].add(to);
							~chain[from][1].add(val);
							~player.stop;
							~chain.writeArchive(tmpfile);
                            dirty = true;
							cond.unhang;
						}.inEnvir);
						cond.hang;
					} {
						"all done".inform;
					};
				};

                //After auditioning, maybe do it again?
                ModalDialog({ |p|
                    CXLabel(p, "Continue?", 300);
                }, {
                    continue = true;
                    cond.unhang;
                }, "Continue?",
                {
                    continue = false;
                    cond.unhang
                });

				cond.hang;

			};

            //After all is done, let's save our work.
            if (dirty) {
                writeFile.value;
            } {
                "Nothing to write.".inform;
            }

        }.inEnvir.fork(AppClock)

	};
	Windo

	~displaySlider = { |from, to, cb|

		var w = Window("% -> %".format(from, to), Rect(0, 0, 200, 400).center_( Window.availableBounds.center )).layout_(HLayout());
        var sl = Slider(w).action_({ |sl|
            w.close;
            cb.value(sl.value);
        });
        w.front;
	};

    ~markovSet = {
        var out = [];
        ~chain.keysValuesDo({ |k, v|
            //We don't normalize weights
            //MarkovSet does that for us
            out = out.add([k, v[0].asArray, v[1].asArray]);
        });
        out
    }

});

/*
~markovMaker.connect(q.player);
~markovMaker.setBounds(3,5);
~markovMaker.initChain;
~markovMaker.train
~markovMaker.markovSet
*/
