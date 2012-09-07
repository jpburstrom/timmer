(
	doSCRender: {
		//Testing automated rendering
		var path ="/Volumes/HD2/projects/timmer/kod/sc/scores/";
		//Later on, we could use "scores/*".do. 
		var pattern = (path +/+ "1.1-Gnid&Drag.scd").load;
		//call the render function. TODO: maxTime 
		topEnvironment.p.doRender(pattern, "/tmp/testing.aiff")
	}
)
