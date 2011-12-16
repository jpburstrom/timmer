//********
// LOADING
//********

(

BP.freeAll;

~dir = ();
~q = ();
~dir.project = "/Volumes/HD2/projects/timmer/kod/sc/";
~dir.lib = ~dir.project ++ "lib/";

//Load lib files 

(~dir.lib ++ "*").loadPaths;

)

*/