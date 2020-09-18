#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import numpy as np
#import subprocess
import sys
sys.path.insert(1, os.path.expanduser('~/code/macaque-dev-brain/imaging/'))
import ImageStitching
import random
random.seed()

# In[2]:


import ray
ray.shutdown()
ray.shutdown()
ray.shutdown()


# In[ ]:


toppath = os.path.expanduser(sys.argv[1])

dirlist=os.listdir(os.path.join(toppath))
random.shuffle(dirlist)
dirlist=[f for f in dirlist if os.path.isdir(os.path.join(toppath,f))]
for f in dirlist:
    dirlist2=os.listdir(os.path.join(toppath,f))
    dirlist2=[d for d in dirlist2 if os.path.isdir(os.path.join(toppath,f,d))]
    for d in dirlist2:
        dirname=os.path.join(toppath,f,d)
        numunstitched=np.sum(['_R_p' in x for x in os.listdir(dirname)])
        ###LOOP THROUGH image areas
        for i in range(4):
            i+=1
            if numunstitched>10:
                print(dirname)
                #df,IF=ImageStitching.ImageJStitchImages(dirname,dirname,'DAPI',str(i),-0.01,1.01,-0.01,1.01)   
                try:
                    random.seed()
                    mm=[0.01,.1,2,20]
                    random.shuffle(mm)
                    ad=[.02,.2,4,30]
                    random.shuffle(ad)
                    for minmax in ad:
                        for absdisp in mm:
                    	    df,IF=ImageStitching.ImageJStitchImages(dirname,dirname,'DAPI',str(i),-0.05,1.05,-0.05,1.05,minmax,absdisp)
                except Exception as e:
                    print(e)
                    print('fail')

