scriptdir='/home/mt/code/'
//clear tmp directory
tmpdir='/home/mt/tmp/'
tmpFileList=getFileList(tmpdir);

fullfiles=getFileList(tmpdir);
tiles=newArray();
print(fullfiles.length);
for (i = 0; i < fullfiles.length; i++) {
	file1=fullfiles[i];
 if(  matches(file1,".*HOECHST*")){
 	print('matches');
  	//tiles = Array.concat(tiles, file1);
 }else {
 	print('Not Matches');
  	tiles= Array.concat(file1,tiles);
 }
}

//Can replace HOECHST with DAPI
run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+tmpdir+"HOECHST.stitchy fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
run("Slice Keeper", "first=1 last=1 increment=1");
rename("HOECHST");
selectWindow("Fused");
run("Close");

for (i = 0; i < tiles.length; i++) { 
   filename =tiles[i];
   print(filename);
   if(endsWith(filename, "stitchy")){
	  	splitted=split(filename,".stitch");
	  	print(splitted[0]);
	  	//replace first column with filenames so stitching is exactly the same
	
	  	//print("awk 'FS=\";\";FNR==NR{a[NR]=$1;next}{$1=a[FNR]}1' "+tmpdir+"HOECHST.stitchy.registered.txt "+tmpdir+splitted[0]+".stitchy > "+tmpdir+splitted[0]+".stitchy.registered.txt");
	  	//exec("awk 'FS=\";\";FNR==NR{a[NR]=$1;next}{$1=a[FNR]}1' "+tmpdir+"HOECHST.stitchy.registered.txt "+tmpdir+splitted[0]+".stitchy > "+tmpdir+splitted[0]+".stitchy.registered.txt");
		//run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+tmpdir+splitted[0]+".stitchy.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	    run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+tmpdir+splitted[0]+".stitchy fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	    run("Slice Keeper", "first=1 last=1 increment=1");
	    rename(splitted[0]);
		selectWindow("Fused");
		run("Close");
	    run("Sharpen");
	    run("Subtract Background...", "rolling=100");
	    //run("Gamma...", "value=1.2");
	    run("Multiply...", "value=2.5");
	    //run("Add...", "value=20");
	    //run("Flip Vertically");
   }
}
run("Images to Stack", "name=Stack title=[] use");

waitForUser('Select Region to crop');
run("Crop");
run("Slice Keeper", "first=4 last=4 increment=1");
selectWindow("Stack");
run("Slice Remover", "first=4 last=4 increment=1");
selectWindow("Stack");
run("Make Composite", "display=Composite");
run("Multiply...", "value=3.8");
run("Stack to RGB");
selectWindow("Stack");
run("Stack to Images");
run("Collect Garbage");
run("Images to Stack", "name=Stack title=[] use");
//run("Enhance Contrast...", "saturated=0.01 equalize");
run("Collect Garbage");


while (1==1) {
	selectWindow("Stack");
	setSlice(1);
	run("Select All");
	run("Duplicate...", "title=Guide");
	selectWindow("Stack");
	waitForUser('Select Region for montage');
	getSelectionBounds(x,y,w,h);
	//Roi.getBounds(x,y,w,h);
	selectWindow("Guide");
	print(x,y,w,h);
	makeRectangle(x,y,w,h);
	run("Draw");
	selectWindow("Stack");
	run("Duplicate...", "duplicate");
	run("In [+]");
	run("In [+]");
	waitForUser('Add arrows');
	txt=getString("What to call montage?", "montage");`
	//txt=regionname+"_"+txt
	run("Make Montage...", "columns=3 rows=2 scale=1.0 label");
	montagename=inputDir1+"../"+tilestring+"_"+txt+".png";
	save(montagename);
	run("Close");
	selectWindow("Guide");
	run("Select All");
	run("Scale...", "x=0.2 y=0.2 interpolation=Bilinear average");
	guidename=inputDir1+"../"+tilestring+"_"+txt+"_Guide"+".png";
	save(guidename);
	run("Close");
	selectWindow("Stack-1");
	run("Close");
	run("Collect Garbage");
	}

