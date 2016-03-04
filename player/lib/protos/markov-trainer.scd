//Automatic manual markov maker
//Audition phrase transitions and tell me how they rock

//TODO: reformat ~chain, save, load

~markovMaker = Proto({

	//Format: key->[[other, other, other], [prob, prob, prob]]
	~chain = ();

	//Connect to a player
	~connect = { |player|
		~player = player;
	};

	~setBounds = { |start=0, end|
		~start = start;
		~end = end ?? { ~player.data[~player.tickLabel].size - 1 };
		~chain = ();
		(start..end).do { |k|
			~chain[k] = List[List(), List()];
		};
		currentEnvironment;
	};
	~train = {
		var order = (~start..~end);
		var toChoose;
		var continue = true;
		var cond = Condition();
		fork {
			while { continue } {
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
							cond.unhang;
						}.inEnvir);
						cond.hang;
					} {
						"all done".inform;
					};
				};

				defer {
					//After auditioning, maybe do it again?
					ModalDialog(nil, {
						continue = true;
						cond.unhang;
					}, "Continue?",
					{
						continue = false;
						cond.unhang
					});
				};

				cond.hang;

			}
		}
	};

	~displaySlider = { |from, to, cb|
		{
			var w = Window("% -> %".format(from, to), Rect(0, 0, 200, 400)).layout_(HLayout());
		var sl = Slider(w).action_({ |sl|
			w.close;
			cb.value(sl.value);
		});
		w.front;
		}.defer
	}


});

/*
~markovMaker.connect(q.player)
~markovMaker.setBounds(3,5)
~markovMaker.train
~markovMaker.chain
*/