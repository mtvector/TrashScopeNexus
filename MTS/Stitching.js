importClass(Packages.ij.IJ);
IJ.run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+arguments[0]+" fusion_method=[Linear Blending] regression_threshold=.001 max/avg_displacement_threshold="+arguments[1]+" absolute_displacement_threshold="+arguments[2]+" compute_overlap subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");

//subpixel_accuracy use_virtual_images
