#!/usr/bin/env python
# coding: utf-8

# In[3]:


import os
import numpy as np
#import subprocess
import sys
sys.path.insert(1, os.path.expanduser('~/code/macaque-dev-brain/imaging/'))
import ImageStitching


# In[2]:


import ray
ray.shutdown()
ray.shutdown()
ray.shutdown()


# In[ ]:


toppath = os.path.expanduser('/wynton/group/ye/mtschmitz/images/MacaqueMotorCortex/')
for f in os.listdir(os.path.join(toppath)):
    for d in os.listdir(os.path.join(toppath,f)):
        dirname=os.path.join(toppath,f,d)
        if os.path.isdir(dirname):
            numunstitched=np.sum(['_R_p' in x for x in os.listdir(dirname)])
            ###LOOP THROUGH image areas
            for i in range(4):
                i+=1
                if numunstitched>10:
                    print(dirname)
                    df,IF=ImageStitching.ImageJStitchImages(dirname,dirname,'DAPI',str(i),.5,.55,.5,.55)
                    #df,IF=ImageStitching.ImageJStitchImages(dirname,dirname,'DAPI',str(i),-1,2,-1,2)
                    #callstring="conda activate imagej && python ~/code/macaque-dev-brain/imaging/ImageStitching.py "+dirname+' '+ dirname+' DAPI '+str(i)+' -1 2 -1 2'
                    #print(callstring)
                    #subprocess.call(callstring, shell=True) 


# In[77]:


from collections import defaultdict
dirname='/wynton/group/ye/mtschmitz/images/MacaqueMotorCortex/E80-20180214_325_20200706/scan.2020-07-08-20-04-44'
protocol='scan.scanprotocol'
n_location=1
counting=False
reference=False
shapes=defaultdict(list)
with open(os.path.join(dirname,protocol), 'r') as f:
    for line in f:
        try:
            if '<d2p1:ScanLocation>' in line:
                counting=~counting
            if counting and '<d10p1:_x>' in line:
                x=float(line.split('>')[1].split('<')[0])
            if counting and '<d10p1:_y>' in line:
                y=float(line.split('>')[1].split('<')[0])
                shapes[str(n_location)].append((x,y))
            if '<d2p1:ReferencePoint ' in line:   
                counting=False
                reference=True
            if reference and '<d10p1:_x>' in line:
                xref=float(line.split('>')[1].split('<')[0])
            if reference and '<d10p1:_y>' in line:
                print('ref',xref)
                yref=float(line.split('>')[1].split('<')[0]) 
                reference=False
                shapes[str(n_location)]=[(x+xref,y+yref) for x,y in shapes[str(n_location)]]
                n_location+=1
                xref=0
                yref=0
        except:
            pass        


# In[78]:


shapes


# In[79]:


import matplotlib
import matplotlib.path as mpltPath

outline = mpltPath.Path(shapes['1'])
outline=outline.transformed(matplotlib.transforms.Affine2D().scale(1.1))
print(outline)
inside = outline.contains_points(shapes['1'])
print(inside)
shapes['1']


# In[30]:


import re
re.sub('.TIF','HAHA','Image1.TIF')


# In[80]:


import shapely
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
polygon = Polygon(shapes['1'])
polygon=shapely.affinity.scale(polygon,xfact=1.1,yfact=1.1)
print([polygon.contains(Point(x,y)) for x,y in shapes['1']])
contains=[polygon.contains(Point(x,y)) for x,y in shapes['1']]


# In[81]:


matplotlib.pyplot.scatter([x[0] for x in shapes['1']], [x[1] for x in shapes['1']])
outside=np.array(shapes['1'])[~np.array(contains)]
matplotlib.pyplot.scatter([x[0] for x in outside], [x[1] for x in outside])


# In[82]:


matplotlib.pyplot.scatter([x[0] for x in shapes['1']], [x[1] for x in shapes['1']])
matplotlib.pyplot.scatter(polygon.exterior.coords.xy[0],polygon.exterior.coords.xy[1])
buffgon = Polygon(polygon.buffer(4500.0).exterior)
matplotlib.pyplot.scatter(buffgon.exterior.coords.xy[0],buffgon.exterior.coords.xy[1])
outside=np.array(shapes['1'])[~np.array(contains)]
matplotlib.pyplot.scatter([x[0] for x in outside], [x[1] for x in outside])
matplotlib.pyplot.savefig('/wynton/scratch/mtschmitz/BufferPolygon.png')


# In[74]:


buffgon


# In[75]:


polygon


# In[ ]:




