//********
// LOADING
//********

//~dir: directories, ~q: assets: d = data, s = samples
BP.freeAll;
Environment.push((dir: (), q: nil));
//Set a few globals 
~dir.project = "/Volumes/Mega/projects/timmer/kod/sc/";
~dir.lib = ~dir.project ++ "lib/";

//Load lib files 

(~dir.lib ++ "*").loadPaths;


//TODO
// ~q.samples


PR(\test_yo) => BP(\foo)

BP(\foo).play
Ptrace(BP(\foo).asStream).play


Ptraac

Pattern
