Proto({

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
            "% items left".format(((order.size * (order.size - 1)) - ~chain.collect { |x| x[0].size }.sum)).inform;

            //If we've chosen not to continue, or if all ~chain slots are filled,
            //stop the operation.
            while { continue and: { ~chain.collectAs({ |x| x[0].size },
                Array).selectIndices(_ != (order.size - 1)).isEmpty.not} } {

                order = order.scramble; //Randomize order for fun
                toChoose = order.rotate(order.size - 1);

                order.do { |from, index|
                    var to;
                    index = index % toChoose.size;
                    if (~chain[from][0].size < (order.size - 1)) {
                        var test = 0;
                        while { (~chain[from][0].includes(toChoose[index]) or: { from == toChoose[index] }) and: { test <= toChoose.size } } {
                            test = test + 1;
                            index = (index + 1) % toChoose.size;
                        };
                        if (test <= toChoose.size) {

                            var callback = { |val|
                                ~chain[from][0].add(to);
                                ~chain[from][1].add(val);
                                if (~bidirectional) {
                                    ~chain[to][0].add(from);
                                    ~chain[to][1].add(val);
                                };
                                ~player.stop;
                                ~chain.writeArchive(tmpfile);
                                dirty = true;
                                cond.unhang;
                            }.inEnvir;

                            to = toChoose.remove(toChoose[index]);

                            ~player.setIterator(Pseq([from, to]));
                            ~player.play;

                            if (~binaryChoice) {
                                ~displayButtons.(from, to, callback);
                            } {
                                ~displaySlider.(from, to, callback);
                            };
                            cond.hang;
                        } {
                            "Couldn't find a new connection. Continuing...".inform;
                        }
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

    ~displaySlider = { |from, to, cb|

        var w = Window("% -> %".format(from, to), Rect(0, 0, 200, 400).center_( Window.availableBounds.center )).layout_(HLayout());
        var sl = Slider(w).action_({ |sl|
            w.close;
            cb.value(sl.value);
        });
        w.front;
    };

    ~displayButtons = { |from, to, cb|
        var w = Window("% -> %".format(from, to), Rect(0, 0, 200, 400).center_( Window.availableBounds.center )).layout_(HLayout());
        var choices = ["No", "Yes"];
        var btns = [1,0].do { |i|
            Button(w).states_([[choices[i]]]).action_({
                cb.value(i);
                w.close;
            });
        };

        w.front;
    };


})