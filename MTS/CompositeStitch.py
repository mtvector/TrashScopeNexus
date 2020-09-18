
import math
from ij import IJ, ImagePlus
from ij.process import FloatProcessor
from ij.process import ImageProcessor as IP
import ij
import csv
import os
import ij.plugin.HyperStackConverter as HSC
from time import sleep
import sys
from ij.gui import Toolbar
from ij import WindowManager
import ij.gui.OvalRoi as OvalRoi
import ij.gui.TextRoi as TextRoi
import re
from ij import IJ
from ij.io import Opener
from ij.plugin import Concatenator
from jarray import array
import ij.gui.GenericDialog as GenericDialog 
import java.awt.Font as Font
import java.awt.Color as Color
import ij.plugin.Duplicator as dup
import re
from ij.io import TiffDecoder
import time
from ij.io import Opener
import gc
gc.collect()
IJ.setForegroundColor(254, 254, 254);
IJ.run("Line Width...", "line=14");

IJ.run("Collect Garbage");
#inputDir1 = IJ.getDirectory("Choose image directory! ")
inputDir1 = "/home/mt/Downloads/1/"
fileList1 = os.listdir(inputDir1); 
###tilestring=getString("Which Tilescan", "1")
RGB=os.path.join(inputDir1,'RGB.png')
	
FileList=sorted(os.listdir(inputDir1))
print(FileList)
stitchedFiles=[x for x in FileList if "stitched.TIF" in x]
stitchedNames=[x.split('_')[0] for x in stitchedFiles]

mergedFiles=[x for x in FileList if "merged.TIF" in x]

imp = Opener.openUsingBioFormats(os.path.join(inputDir1,mergedFiles[0]))
xsize=imp.getWidth()
ysize=imp.getHeight()
imp.close()

print(xsize,ysize)

for im in stitchedFiles:
    if not "hoechst" in im.lower():
        IJ.open(inputDir1+im)
        imp = IJ.getImage()
        imp.setTitle(im.split('_')[0])
IJ.run("Images to Stack", "name=Stack title=[] use")
imp = IJ.getImage()
#IJ.run("Multiply...", "value=2.2")
IJ.beep()

gd = GenericDialog("Clockwise Rotation?")
gd.addChoice("How Many Degrees",["0","90","180",'270'],"0")
gd.showDialog()
rotation = gd.getChoices().get(0).getSelectedItem()

#in while loop
while True:
	IJ.run("Stack to Images")
	IJ.run("Images to Stack", "name=Stack title=[] use")
	imp = IJ.getImage()
	myWait = ij.gui.WaitForUserDialog('Select Region to Load Full Res')
	myWait.show()
	region=IJ.getString("What to call region?", "")
	print(region)
	
	width=imp.getWidth()
	height=imp.getHeight()
	roi=imp.getRoi()
	xmin=roi.bounds.getMinX()/width
	xmax=roi.bounds.getMaxX()/width
	ymin=roi.bounds.getMinY()/height
	ymax=roi.bounds.getMaxY()/height
	print(dir(imp))
	
	IJ.run("Make Composite", "display=Composite")
	IJ.run("Select All")
	#IJ.run("Multiply...", "value=2.0")
	IJ.run("Stack to RGB")
	imp= IJ.getImage()
	imp.setRoi(roi)
	IJ.run("Draw")
	IJ.run("Select All")
	IJ.run("Scale...", "x=0.2 y=0.2 interpolation=Bilinear average")
	IJ.run("Select All")
	IJ.run("Rotate...", "angle="+rotation + " grid=0 interpolation=Bilinear stack")
	IJ.saveAs(imp, "png", os.path.join(inputDir1,region+'_guide.png'))
	IJ.run("Close");
	IJ.run("Collect Garbage")
	gc.collect()
	stitchmaxX=0
	stitchmaxY=0
	pattern = re.compile('(.*);(.*);(.*)\((.*),(.*)\)(.*)')
	
	stitchyFiles=[x for x in FileList if "_merged.stitchy" in x]
	stitchyFile=os.path.join(inputDir1,stitchyFiles[0])
	#first get maxvals from file
	with open(stitchyFile,'r') as the_file:
	    for l in the_file.readlines():
	        res = re.search(pattern, l)
	        if res is not None:
	            stitchX=float(res.group(4))
	            stitchY=float(res.group(5))
	            if stitchX>stitchmaxX:
				    stitchmaxX=stitchX
	            if stitchY>stitchmaxY:
				    stitchmaxY=stitchY
	
	stitchmaxX=stitchmaxX+xsize
	stitchmaxY=stitchmaxY+ysize
	newlines=[]
	#then get values within range			    
	with open(stitchyFile,'r') as the_file:
	    for l in the_file.readlines():
	        res = re.search(pattern, l)
	        if res is not None:
	            stitchX=float(res.group(4))
	            stitchY=float(res.group(5))
	            print('x:',xmin,xmax,stitchX/stitchmaxX)
	            print('y:',ymin,ymax,stitchY/stitchmaxY)
	            if (stitchX/stitchmaxX < xmax) and ((stitchX+xsize)/stitchmaxX > xmin) and (stitchY/stitchmaxY < ymax) and ((stitchY+ysize)/stitchmaxY >ymin):
	                print(l)
	                newlines.append(l)
	        else:
	            newlines.append(l)
	
	newstitchy=os.path.join(inputDir1,'tmp.stitchy')
	with open(newstitchy, 'w') as newf:
	    newf.writelines(newlines)
	
	#Rotating images
	
	#save guide image
	#IJ.run("Make Composite", "display=Composite");
	#IJ.run("Multiply...", "value=2.2");
	#IJ.run("Stack to RGB");
	#IJ.selectWindow("Stack");
	#IJ.run("Close");
	
	#Load full res
	IJ.run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+inputDir1+" layout_file=tmp.stitchy fusion_method=[Linear Blending] regression_threshold=0.40 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	IJ.run("Select All")
	#rotate with previous rotation
	IJ.run("Rotate...", "angle="+rotation + " grid=0 interpolation=Bilinear stack")
	
	myWait = ij.gui.WaitForUserDialog('Select region to crop!')
	IJ.run("Collect Garbage");
	myWait.show()
	IJ.run("Crop")
	
	#subtract background
	IJ.run("Subtract Background...", "rolling=100 stack")
	#Order slices alphabetically
	gene_names=sorted(stitchyFiles[0].split('_'))
	gene_names=[x for x in gene_names if "stitchy" not in x]
	print(gene_names)
	
	imp = IJ.getImage()
	IJ.run("Stack to Images")
	titles=sorted(WindowManager.getImageTitles())
	titles=[x for x in titles if "stack" not in x.lower()]
	colors=['Red','Green','Blue']
	hoechstind=0
	colorind=0
	for i in range(len(titles)):
	    imp=WindowManager.getWindow(titles[i])
	    #IJ.selectWindow(imp.getTitle())
	    print(gene_names[i])
	    imp.setTitle(gene_names[i])
	    imp.getImagePlus().setTitle(gene_names[i])
	    WindowManager.setWindow(imp)
	    imp.setTitle(gene_names[i])
	    WindowManager.setCurrentWindow(imp)
	    #IJ.run('Rename...',gene_names[i])
	    if gene_names[i].lower() =='hoechst':
	        IJ.run('Cyan')
	        hoechstind=i
	        print("HOECHST CAUGHT")
	    else:
	        print(imp.getTitle())
	        IJ.run(colors[colorind])
	        colorind+=1
	    
	hoechstind=str(hoechstind)
	#Make RGB not including hoechst
	mergestring=[]
	ind=1
	for i in range(len(gene_names)):
	    if gene_names[i].lower()!='hoechst':
			mergestring.append('c'+str(ind)+'='+gene_names[i])
			ind+=1
	print(mergestring)
	IJ.run("Merge Channels...", " ".join(mergestring) + " create keep")
	IJ.run("Stack to RGB")
	IJ.selectWindow("Composite")
	IJ.run("Close")
	IJ.run("Images to Stack", "name=compstack use")
	
	
	myWait = ij.gui.WaitForUserDialog('Add arrows!')
	myWait.show()
	
	gd = GenericDialog("Montage downscale factor?")
	gd.addChoice("Factor:",["1.0",".25",".1"],"1.0")
	gd.showDialog()
	scale = gd.getChoices().get(0).getSelectedItem()
	
	IJ.run("Make Montage...", "columns=3 rows=2 scale="+scale+" label")
	montagename=os.path.join(inputDir1,region+"_montage.png")
	IJ.save(montagename)
	IJ.run("Close")
	IJ.run("Collect Garbage")
	IJ.selectWindow("compstack")
	IJ.run("Close")
	IJ.run("Collect Garbage")
	gc.collect()



#######################

'''
imp=WindowManager.getWindow('compstack').getImagePlus()
gene_names=gene_names+['Merged']
print(imp.getNSlices())
print(imp.getDimensions())
for i in range(len(imp.getNSlices())):
    imp.setPosition(0,i,0)
    IJ.run('Rename...',gene_names[i])
'''
#IJ.run("Slice Keeper", "first="+hoechstind+" last="+hoechstind+" increment=1")
#IJ.selectWindow("compstack");
#IJ.run("Slice Remover", "first="+hoechstind+" last="+hoechstind+" increment=1")
#IJ.selectWindow("compstack");
#IJ.run("Make Composite", "display=Composite");
#IJ.run("Multiply...", "value=2");
#IJ.selectWindow("compstack");
#IJ.run("Stack to Images");
#IJ.run("Collect Garbage");
#IJ.run("Images to Stack", "name=compstack title=[] use");

