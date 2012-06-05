//********
// LOADING
//********

(
Server.local.options.device = "UA-25 48kHz";

s.waitForBoot {
	BP.freeAll;
	
	~dir = ();
	~q = ();
	~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
	~dir.lib = ~dir.project ++ "lib/";
	
	//Load lib files 
	
	(~dir.lib ++ "*").loadPaths;
	//(~dir.project ++ "live.scd").loadPaths;
	
	s.meter
};
)

//NdefMixer(s)

//~show.start