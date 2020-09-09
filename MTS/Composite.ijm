
run("Collect Garbage");
inputDir1 = getDirectory("Choose image directory! "); 
fileList1 = getFileList(inputDir1); 
tilestring=getString("Which Tilescan", "TR1")
tiles=newArray()

for (i = 0; i < fileList1.length; i++) {
	file1=fileList1[i];
 if(  matches(file1,".*d1.*")){
 	print('matches');
  	tiles = Array.concat(tiles, file1);
 }else {
 	print('Not Matches');
  	tiles= Array.concat(file1,tiles);
 }
}

for (i = 0; i < tiles.length; i++) { 
   filename =tiles[i]; 
	if (i < lengthOf(tiles) - 1) {
		nextFilename = tiles[i + 1];
	}
   print(filename);
   if(endsWith(filename, "TIF")){
   	  if(matches(filename, ".*"+tilestring+".*")){
   	  	//run("Preloader", "current=" + filename + " next=" + nextFilename);
   	  	open(filename);
  	    selectWindow(filename);
  	    splitted=split(filename,"_");
  	    rename(splitted[0]);
  	    run("Sharpen");
  	    run("Subtract Background...", "rolling=100");
  	    //run("Gamma...", "value=1.2");
  	    run("Multiply...", "value=2.2");
  	    //run("Add...", "value=20");
  	    //run("Flip Vertically");
      }
   }
}

//run("Merge Channels...", "c1=[FOXP2_scan_Bottom Slide_TR1_p00_0_A01f00d0.TIF] c2=[SCGN_scan_Bottom Slide_TR1_p00_0_A01f00d3.TIF] c3=[ETV1_scan_Bottom Slide_TR1_p00_0_A01f00d2.TIF] c4=[HOECHST_scan_Bottom Slide_TR1_p00_0_A01f00d1.TIF] create");
//selectWindow("Composite");
//run("Split Channels");
run("Images to Stack", "name=Stack title=[] use");
waitForUser('Select Region to Crop');
run("Crop");
run("Slice Keeper", "first=4 last=4 increment=1");
selectWindow("Stack");
run("Slice Remover", "first=4 last=4 increment=1");
selectWindow("Stack");
run("Make Composite", "display=Composite");
run("Multiply...", "value=3.1");
run("Stack to RGB");
selectWindow("Stack");
run("Stack to Images");
run("Collect Garbage");
run("Images to Stack", "name=Stack title=[] use");
//run("Enhance Contrast...", "saturated=0.01 equalize");
run("Collect Garbage");
setForegroundColor(254, 254, 254);
run("Line Width...", "line=8");
while (1==1) {
	selectWindow("Stack");
	setSlice(2);
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
	txt=getString("What to call montage?", "montage");
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

