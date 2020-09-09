scriptdir='/home/mt/code/'
//clear tmp directory
tmpdir='/home/mt/tmp/'
tmpFileList=getFileList(tmpdir);

for (i = 0; i < tmpFileList.length; i++) { 
    if(endsWith(tmpFileList[i], "dummy")){
    File.delete(tmpdir+tmpFileList[i]);
    }
    if(endsWith(tmpFileList[i], "TIF")){
    print(tmpFileList[i]);
    File.delete(tmpdir+tmpFileList[i]);
    }   
   	if(endsWith(tmpFileList[i], "stitchy")){
    print(tmpFileList[i]);
    File.delete(tmpdir+tmpFileList[i]);
    }   
}

setForegroundColor(254, 254, 254);
run("Line Width...", "line=10");


function escapePath(p) {
pF=replace(p,"\\ ","\\\\ ");
return pF;
}

run("Collect Garbage");
inputDir1 = getDirectory("Choose image directory! "); 
fileList1 = getFileList(inputDir1); 
tilestring=getString("Which Tilescan", "TR1")
RGB=inputDir1+tilestring+'_RGB.TIF'
if(File.exists(RGB)==0){
tiles=newArray()

for (i = 0; i < fileList1.length; i++) {
	file1=fileList1[i];
 if(  matches(file1,".*d1.*")){
 	print('matches');
  	//tiles = Array.concat(tiles, file1);
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
  	    run("Multiply...", "value=2.5");
  	    //run("Add...", "value=20");
  	    //run("Flip Vertically");
      }
   }
}

run("Images to Stack", "name=Stack title=[] use");
run("Make Composite", "display=Composite");
run("Multiply...", "value=3.8");
run("Stack to RGB");
selectWindow("Stack");
run("Close");
save(RGB);
}else{
for (i = 0; i < fileList1.length; i++) {
	filename=fileList1[i];
 if(  matches(file1,".*d1.*")){
 	print('matches');
 	if(matches(filename, ".*"+tilestring+".*")){
   	  	//run("Preloader", "current=" + filename + " next=" + nextFilename);
   	  	open(filename);
  	    selectWindow(filename);
  	    splitted=split(filename,"_");
  	    rename(splitted[0]);
  	//tiles = Array.concat(tiles, file1);
 }else {
 	print('Not Matches');
 }
}

	}
beep();                                              //alert the user
waitForUser('Select Region to Reload in full definition');
Stack.getDimensions(width, height, channels, slices, frames);
getSelectionBounds(x,y,w,h);
run("Draw");
regionname=getString("What to call region?", "region");
guidefile=inputDir1+"../"+regionname+".png";
save(guidefile);
run("Close");

//#dirname,dirout,stitchchannel,chosenstitchgroup,x1lim,x2lim,y1lim,y2lim=sys.argv
callstring=scriptdir+"RunPy.sh" +" "+ escapePath(inputDir1)+" "+ escapePath(tmpdir)+" DAPI "+tilestring+" "+
toString(x/width,2)+" "+toString((x+w)/width,2)+" "+
toString(y/height,2)+" "+toString((y+h)/height,2);
print(callstring);
beep();                                              //alert the user
exec(callstring); 
while (File.exists(tmpdir+'dummyfile.dummy')==0) {
// Nothing needed here. Just wait for plugin to end.
//If the file hangs at this point, something has broken in the RunPy.sh call
}

fullfiles=getFileList(tmpdir);
tiles=newArray();
print(fullfiles.length);
for (i = 0; i < fullfiles.length; i++) {
	file1=fullfiles[i];
 if(  matches(file1,".*HOECHST*")){
 	print('matches');
  	tiles = Array.concat(tiles, file1);
 }else {
 	print('Not Matches');
  	tiles= Array.concat(file1,tiles);
 }
}

//Can replace HOECHST with DAPI
//run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+tmpdir+"HOECHST.stitchy fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
//run("Slice Keeper", "first=1 last=1 increment=1");
//rename("HOECHST");
//selectWindow("Fused");
//run("Close");

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
	    run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[] layout_file="+tmpdir+splitted[0]+".stitchy fusion_method=[Linear Blending] regression_threshold=0.40 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
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
beep();                                              //alert the user
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
	txt=getString("What to call montage?", "montage");
	txt=regionname+"_"+txt
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

