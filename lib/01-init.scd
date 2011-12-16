// Main sets main project dir, then we do this dance.
BP.freeType(\assets);

~q = Proto({
	~d = ();
	~s = ();
	
	//Return paths for \dir, \label | [\array, \of, \labels]
	~paths = { |dir, label|
		var out=Array.new;
		(label.size == 0).if { label = [label] };
		label.do {Ê|lab|
			lab.postln;
			(~s[dir][lab].size == 0).if ( {
				out = out.add(~s[dir][lab].path)
			}, {
				out = out ++ ~s[dir][lab].collect(_.path)
			});
		};
		out
	};
	~sf = { |dir, label|
		~s[dir][label]
	}
	
}, parentKeys: #[d, s]);


~dir.data = ~dir.project ++ "data/";
~dir.samples = ~dir.project ++ "samples/";

//Load all asset files, put them in ~q 
(~dir.data ++ "*").pathMatch.do { |p| ~q.d[p.basename.splitext[0].asSymbol] = p.load } ;
//Were assuming samples/subdir/file.wav, replacing spaces & hyphens for underscore (to work as symbol)
(~dir.samples ++ "*").pathMatch.do( { |p|
	var sub = p.basename.splitext[0].asSymbol;
	~q.s[sub] = ();
	(p ++ "*").pathMatch.do( { |x|
		(x.isFile).if ( {
			~q.s[sub][x.basename.splitext[0].tr($ , $_).tr($-, $_).tr($., $_).asSymbol] = SoundFile(x).info;
		}, {
			~q.s[sub][x.basename.asSymbol] = SoundFile.collect(x ++ "*").do(_.info);
		});
	})
});

~q => PR(\q).subType_(\assets) => BP(\q);