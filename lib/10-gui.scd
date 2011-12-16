// 
CocoaMenuItem.clearCustomItems;

CocoaMenuItem.add(["Reload All"], { (~dir.lib ++ "*").loadPaths; }).setShortCut("a", false, true);
CocoaMenuItem.add(["Reload Assets"], { (~dir.lib ++ "01-init.scd").loadPaths; }).setShortCut("r", false, true);
