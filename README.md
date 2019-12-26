Dockerfiles
===========

A set of Docker images that I use on my servers.

All Dockerfiles do not exist in place. The files in this repository are templates, and the real Dockerfiles are generated with **GPP (General Purpose Preprocessor)**. See **Makefile** for details.

Directory Structure
-------------------

- **dockerfiles:** template files for individual images.
  - Each subfolder is one image
  - **template.Dockerfile** define how real **Dockerfile** is generated
  - Ready to use images available at [xddxdd @ Docker Hub](http://hub.docker.com/r/xddxdd), but you shouldn't use them (or blindly update them), since I change them on my will, without considering backwards compatibility
- **include:** common parts of template files, including image definition, frequently used commands, etc.
  - Like headers in C++.
- **unmaintained:** template files for images that I no longer maintain
  - Because I no longer use them, or upstream deleted their code, etc.
  - Old images are still available at [xddxdd @ Docker Hub](http://hub.docker.com/r/xddxdd)

License
-------

Public domain.