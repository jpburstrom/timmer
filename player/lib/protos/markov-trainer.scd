//Automatic manual markov maker
//Audition phrase transitions and tell me how they rock
var p = Proto({

	//Format: key->[[other, other, other], [prob, prob, prob]]
    ~chain = nil; //Don't initialize yet

    //Set this to true if choice would be yes/no rather than a
    //scale from 0-1
    ~binaryChoice = false;

    //Set this to true if a connection should be the same both ways
    //(setting 1->2 to x also sets 2->1)
    ~bidirectional = false;


	//Connect to a player
	~connect = { |player|
		~player = player;
	};

	~setBounds = { |start=0, end|
		~start = start;
        ~end = end ?? { ~player.data[~player.tickLabel].size - 1 };
        [~start, ~end]
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




});

//Import methods from markov-trainer-gui if not running headless
if (\GUI.asClass.notNil) {
    p.putAll("markov-trainer-gui".import.parent);
};

p

/*
~markovMaker.connect(q.player);
~markovMaker.setBounds(3,5);
~markovMaker.initChain;
~markovMaker.train
~markovMaker.markovSet
*/
