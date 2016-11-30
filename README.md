# OMERO on Singularity

## Prerequisites
* Singularity 2.2

Installation instructions can be found on the [Singularity website](http://singularity.lbl.gov/docs-quick-start-installation). You can also refer to the [Singularity GitHub repository](https://github.com/singularityware/singularity).

## Getting started
```
sudo make build
make run
```
To connect to OMERO, you can use the web interface OMERO.web, or the desktop application [OMERO.insight](http://downloads.openmicroscopy.org/omero/5.2.6/). For both, login credentials are required: the system starts off with the `root` admin user with the password `password`.

### Using OMERO.web
Once the above commands have been run, open a web browser of choice and go to the URL localhost:8080, assuming you are running locally. Enter the starting credentials (`root`, `password`).

If you are warned of incorrect credentials, wait a minute or two and try again -- the initial database setup can take some time to run (only happens on first launch), and the server process can also take a few seconds to start up.

### Using OMERO.insight
Once the image is running, open the OMERO.insight client. On Linux, you would run
```
~ > OMERO.insight-5.2.6-ice35-b35-linux/OMEROinsight_unix.sh
```
though this may depend on where you chose to save and extract the client to.

Similar to the process for OMERO.web, enter the starting credentials (`root`, `password`), and try again after waiting if necessary.
