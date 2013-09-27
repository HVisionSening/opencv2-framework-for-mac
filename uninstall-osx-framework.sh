#!/bin/bash

sudo rm -rf /Library/Frameworks/OpenCV2.framework
sudo rm -f /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv2.so
sudo rm -f /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv.py
sudo rm -f /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/cv2.so
sudo rm -f /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/cv.py
sudo pkgutil --forget biz.kyogoku.apps.OpenCV2-framework
echo "Done."
