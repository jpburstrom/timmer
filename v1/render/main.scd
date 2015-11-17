//********
// LOADING
//********

(
	var versions = 500;
	var path = "/Volumes/Mega/projects/timmer/kod/sc/";
	var render = (path +/+ "render/*").loadPaths.reduce(
		{ arg a, b; a.putAll(b) } ;
	);

	//prepareReaperRender

  /*versions.do {
		//doSCRender
		//doReaperRender

		"RENDER".postln
	};
	*/
   render.postln;
   render.prepareReaperRender;
   render.doReaperRender;


	"DONE"

)
