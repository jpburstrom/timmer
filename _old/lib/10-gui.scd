// 
//CocoaMenuItem.clearCustomItems;
var group;

~timmerMenu !? {
	(~timmerMenu.lastIndex != 0).if { ~timmerMenu.remove; }
};

~timmerMenu = SCMenuGroup(nil, "Timmer", 7);

group = SCMenuGroup(~timmerMenu, "lib");
SCMenuItem(~timmerMenu, "main.scd").action_({ (~dir.project ++ "main.scd").openDocument });

(~dir.lib ++ "*").pathMatch.do( {Ê|x|
	SCMenuItem(group, x.basename).action_( { x.openDocument })
});
SCMenuSeparator(~timmerMenu, 2); // add a separator
SCMenuItem(~timmerMenu, "Reload All").action_({ (~dir.lib ++ "*").loadPaths; }).setShortCut("a", false, true);
SCMenuItem(~timmerMenu, "Reload Assets").action_({ (~dir.lib ++ "01-init.scd").loadPaths; }).setShortCut("r", false, true);


