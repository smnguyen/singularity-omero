# OMERO on Singularity

## Prerequisites
* Singularity 2.2

Installation instructions can be found on the [Singularity website](http://singularity.lbl.gov/docs-quick-start-installation).
You can also refer to the [Singularity GitHub repository](https://github.com/singularityware/singularity).

## Getting started
```
sudo make build
make run
```
To connect to OMERO, you can use the web interface OMERO.web, or the desktop application [OMERO.insight](http://downloads.openmicroscopy.org/omero/5.2.6/).
For both, login credentials are required: the system starts off with the `root` admin user with the password `password`.

### Using OMERO.web
Once the above commands have been run, open a web browser of choice and go to the URL localhost:8080, assuming you are running locally.
Enter the starting credentials (`root`, `password`).

If you are warned of incorrect credentials, wait a minute or two and try again.
The initial database setup can take some time to run (only happens on first launch), and the server process can also take a few seconds to start up.

### Using OMERO.insight
Once the image is running, open the OMERO.insight client. On Linux, you would run
```
~ > OMERO.insight-5.2.6-ice35-b35-linux/OMEROinsight_unix.sh
```
though this may depend on where you chose to save and extract the client to.

Similar to the process for OMERO.web, enter the starting credentials (`root`, `password`), and try again after waiting if necessary.

## Changing the OMERO root password
To better secure the OMERO instance, you will want to change the password for the `root` user from `password` to something else.
The easiest way to do this is by using the OMERO web interface.

First, login as the `root` user, and then once inside, click the user dropdown menu at the top right.
Inside the dropdown, click the "User settings" link.
On the settings page, click the button "Change Password" to change the `root` user's password.

## Administration

### Ports
Ports can be configured on the command-line. See `omero_sherlock.sh` for an example. The ports also have default values, which can be found in the `%runscript` section of `omero.def`.

### Other OMERO configuration
Many properties of OMERO that are configurable are listed [here](https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/config.html). To modify these settings, add commands to `run/server.sh` or `run/web.sh` as appropriate.

### PostgreSQL and nginx configuration
Currently, there's no way to easily do this, though no changes should need to be made for a simple OMERO setup.

To modify PostgreSQL, you can edit `postgres/postgresql.conf` after the database cluster has been setup the first time.
For safety, backup the configuration and stop the OMERO cluster before making changes.

To modify nginx, you can edit `run/nginx.conf`.
For changes to OMERO.web's nginx configuration, you will need to `make shell` into the container, and then edit `/etc/nginx/sites-available/omero.conf` inside the container.
Similarly, backup the configuration and stop the OMERO cluster before making changes.
Also note that `run/nginx.sh` replaces `/etc/nginx/sites-available/omero.conf` whenever nginx is restarted -- comment out the relevant line in `run/nginx.sh` if changes to the OMERO.web nginx configuration are made.

## Future enhancements

### Harder tasks
* Create a client-side Docker or Singularity image with install dependencies to allow users to run scripts against an OMERO server, like those in the `tutorials` directory.
* Via a command-line flag or an environment variable, an administrator should be able to easily enable
secure connections (`https`) to OMERO.web.
  * An example nginx configuration can be found [here](https://github.com/smnguyen/docker-omero/blob/dev/omero-web/nginx_omero_ssl.conf).
    This is very similar to the generated configuration in [`run/nginx.sh`](https://github.com/smnguyen/singularity-omero/blob/b52bb23b5665eba5d48048b134b9a8ed8284006c/run/nginx.sh#L10).
  * To support SSL, certificates need to be generated. A free way of doing this is using [Let's Encrypt](https://letsencrypt.org/).
* To speed up the image build process, consider switching to building Docker images that are converted to Singularity images using [docker2singularity](https://github.com/singularityware/docker2singularity).
* An administrator should easily be able to add [OMERO.web plugins](https://www.openmicroscopy.org/site/support/omero5.2/developers/Web/WebclientPlugin.html).
  * Examples of plugins are:
    * [OMERO.webtagging](http://help.openmicroscopy.org/web-tagging.html)
    * [OMERO.figure](http://figure.openmicroscopy.org/)
  * Plugins may have dependencies that require modification of the image -- consider switching to a docker2singularity build process to make this process easier, as described in the last bullet point.
* Build a web plugin to allow users to easily add OME Data Model elements to OMERO, and link their images to those Data Model elements, without having to write code using the OMERO APIs to do so.
  * Tasks like adding an Instrument or filling out details on Channels don't seem possible in the existing UI -- I could be wrong though!

### Quick tasks
* Install a text editor (vim, emacs, or something else) to allow admins to more easily make changes to the configuration.
* Install more up-to-date Python libraries (matplotlib, scipy, pytables, among others) while still maintaining compatibility with OMERO.
  * matplotlib, scipy, and pytables are installed using the apt repositories, which aren't kept updated with the latest versions.
    However, installing using the apt repositories is still useful, since it handles installation of other dependencies for those libraries.
* Rebuild the image for OMERO 5.3 once released.

## Useful links
* [OMERO user help](http://help.openmicroscopy.org/index.html)
* [OMERO developer documentation](https://www.openmicroscopy.org/site/support/omero5.2/developers/index.html)
* [OMERO sysadmin documentation](https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/index.html)
* [PostgreSQL 9.4 documentation](https://www.postgresql.org/docs/9.4/static/index.html)
* [nginx documentation](https://www.nginx.com/resources/wiki/)
* [Supervisor documentation](http://supervisord.org/)

Many other links are scattered throughout comments in the code.
