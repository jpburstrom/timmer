//********
// LOADING
//********

//~dir: directories, ~q: assets 
Environment.push((dir: (), q: (data: (), samples: ())));
//Set a few globals 
~dir.project = "/Volumes/Mega/projects/timmer/kod/sc/";
~dir.lib = ~dir.project ++ "lib/";

//Load lib files 

(~dir.lib ++ "*").loadPaths

//Execute it 

//TODO
