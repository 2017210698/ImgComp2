#! /usr/bin/env python


import urllib
for i in range(1,48):
	img_url  = 'http://decsai.ugr.es/cvg/CG/images/base/'+str(i)+'.gif'
	img_file = str(i)+'.gif'
	urllib.urlretrieve(img_url,img_file)
