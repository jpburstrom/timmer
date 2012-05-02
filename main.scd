//********
// LOADING
//********

(
Server.local.options.device = "JackRouter";
s.waitForBoot {
	BP.freeAll;
	
	~dir = ();
	~q = ();
	~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
	~dir.lib = ~dir.project ++ "lib/";
	
	//Load lib files 
	
	(~dir.lib ++ "*").loadPaths;
}
)

*/

~q.s.banks.hits.choose().asBuffer(s)
SoundFile
Synth.new("timmer.hit", [\bufnum, ~q.s.banks.hits.choose()]);


(
BP(\midiTest).free;
PR(\midiWrapper).v.clone({
	
	~playerPattern = { BP(\test) } ;
	
	
}) => PR(\midiTest).subType_(\timmerMidi) => BP(\midiTest)
)

s.boot
BP(\test).play
BP(\midiTest).asPattern
BP(\test).amp_(Pkey(\pos))

Pkey
BP(\tm).setEmbedBP(\test)

BP(\tm).stop
BP(\tm).embed(\test)
BP(\tm).amp_(Pkey(\pos))
BP(\tm).play

Pbind (\note, Pseq([1,3,4,5,6], inf)).play


p.asPattern.isStream
\

Pbind(\BP(\tm))
BP(\tm).playing

BP(\tm).size

EVent_types