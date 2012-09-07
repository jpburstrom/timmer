//********
// LOADING
//********

(
	var versions = 500;
	var path = "/Volumes/HD2/projects/timmer/kod/sc/";
	var render = (path +/+ "render/*").loadPaths.reduce(
		{ arg a, b; a.putAll(b) } ;
	);
	
	//prepareReaperRender

  versions.do {
		//doSCRender
		//doReaperRender

		"RENDER".postln
	};
	
	"DONE"

)
