OpenCV2 Framework for Mac
=========================

©2013 kyogoku42 <me@kyogoku.biz>

OpenCV2 Framework for Mac is a [OpenCV2](http://opencv.org/) distribution for Mac.  
It aims to provide a OpenCV in a mac-way -- easy to use
and works with all default softwares.

It's now based on __OpenCV 2.4.6.1__.

It comes with what you need.

* OpenCV2.framework
  * Mac-styled framework. (OpenCV 2.4.6.1)
* Binding for Apple Python
  * Binding for Apple's default python (2.7.2).
  * Works with default numpy (1.6.1)
* Binding for Python.org python
  * Binding for [python.org](http://www.python.org/download/) python (2.7.5).
  * Works with [official numpy](http://sourceforge.net/projects/numpy/) (1.7.1).
  * Optional: works with [official scipy](http://sourceforge.net/projects/scipy/).
 * Binding for Apple Java (not tested.)

Currently it supports only OS X Mountain Lion. Works both for 32/64-bit Intel.

Install
-------

**NOTICE:** You must install python.org python  **BEFORE INSTALLING FRAMEWORK** if you need a binding for it.  
You can get at [python.org](http://www.python.org/download/).
You also need to install [official numpy](http://sourceforge.net/projects/numpy/). Optionally, you can install [official scipy](http://sourceforge.net/projects/scipy/). All comes with binary.

To install,

 * Download `OpenCV2 Framework.pkg` inside a folder `OSX-Installer`.
 * Double click and install it. That's it :)

Uninstall
---------

Download and run `uninstall-osx-framework.sh`.

Compile
-------

You can compile Framework by yourself, with additional options. To compile, you need CMake and Xcode (with Command Line Tools).

To build a framework,

    git clone https://github.com/kyogoku42/opencv2-framework-for-mac.git
    cd opencv2-framework-for-mac
    ./build-osx-framework.sh

Framework will be put into `OSX-Frameworks`.

To build an installer,

    cd OSX-Installer
    ./build-osx-installer.sh

Installer will be put into `OSX-Installer`.

To change compiling options, edit `build-osx-framework.sh`.

Changes
-------

Compared to official [OpenCV 2.4.6.1](http://opencv.org/downloads.html):

 * Merged a fix for `dpstereo.cpp`. [See this.](http://code.opencv.org/projects/opencv/repository/revisions/e9b9a6fc038fc243e2debcc1dabd0d0745ff39d6/diff/modules/legacy/src/dpstereo.cpp)
 * Added a `framework` build script in `platforms/osx`.
   * Based on [this](http://www.atinfinity.info/wiki/index.php?OpenCV%2FOpenCV%202.4.6.1%20Framework%20for%20Mac%20OS%20X) and fixed/rewritten in more mac-way.
   * All compile options are reset to default except:
     * ON: AVFoundation.
     * OFF: Documents, Tests, Perforemance tests.
 * Added a new module `pythonorg` in `modules`, which is a second python binding for python.org python.
 * Puts training data into `OpenCV2.framework/Resources/data`.