importClass(Packages.ij.IJ);
imp = IJ.openImage(arguments[1]);
IJ.run(imp, "Subtract Background...", "rolling=150");
IJ.saveAs(imp, "Tiff", arguments[1])
imp.close();
