~p.addPrep(\patterns, {
  (~p.s.currentPath +/+ "scores/patterns/common.scd").load;
  (~p.s.currentPath +/+ "scores/patterns/" ++ ~p.name ++ ".scd").load

}.inEnvir(topEnvironment) , 0);
