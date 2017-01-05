# Current setup on Sherlock
## Launching OMERO
There is currently a cronjob running on `sherlock-ln02` -- the crontab line is a comment in `omero_sherlock.sh`.
At 12:01 AM daily, `share_job.sh` runs and submits `omero_sherlock.sh` to the SLURM work queue to run for 23 hours and 30 minutes.
This run-time of less than 24 hours ensures that there is only one instance of OMERO running at a time.

## File system setup
On Sherlock, this repository is at the directory `$PI_HOME/omero` for the Covert lab.
Ordinarily, running the Singularity container using the `Makefile` would create the folders `data`, `postgres`, `var`, and `user_scripts` in `$PI_HOME/omero`, and these folders would store uploaded data and logs from OMERO.
However, since there is relatively limited space on `$PI_HOME`, OMERO data should actually be on `$PI_SCRATCH`.
Thus, `data`, `postgres`, `var`, and `user_scripts` are instead symbolic links to corresponding directories in `$PI_SCRATCH/omero`.

## Connecting to OMERO
Ideally, `share_job.sh` would SSH tunnel two ports, the OMERO.server port and the OMERO.web port, to the compute node OMERO is running on from `sherlock-ln02`.
Users would then be able to SSH tunnel to the same two ports on `sherlock-ln02` from their local machines to access OMERO.
However, this does not seem to work -- connections to the tunneled ports from local machines are refused.

As a workaround, I can fully tunnel through to a Sherlock compute node using the following command:
```
ssh -t -L 8080:localhost:28080 -L 4064:localhost:24064 smnguyen@sherlock.stanford.edu ssh -L 28080:localhost:28080 -L 24064:localhost:24064 sh-8-30
```
replacing `sh-8-30` with the actual compute node OMERO is running on that day.
The compute node can be found by running
```
squeue -u smnguyen
```
on any login node on Sherlock.
However, this full tunneling may not work for other users unless they have a job running on that same compute node.
Sherlock seems to reject connecting to a compute node unless you have a job running on it.

## Loading images onto OMERO
To create OME-TIFF files that can be loaded into OMERO, I created an ImageJ/Fiji script to convert separated image slices from a directory (how data in the Covert lab is currently stored) into a single OME-TIFF file -- see `util/convert_ome_tiff.py` for more details. Unfortunately, this script does not load the metadata in `metadata.txt` into OMERO.

Ideally, one could simply take the Micro-Manager metadata file `metadata.txt` and use that to convert to OME-TIFF using the Bio-Formats plugin in Fiji.
[See documentation.](https://www.openmicroscopy.org/site/support/bio-formats5.3/formats/micro-manager.html)
However, two circumstances prevent this from happening.
First, the lab stores the image files as PNG instead of the original TIFF to save disk space -- Bio-Formats fails to recognize the PNG files as linked to the corresponding `metadata.txt` file.
Second, the lab is using a version of Micro-Manager (a beta of 2.0) unsupported by the Bio-Formats converter for Micro-Manager (up to 1.4.22).
Options to resolve this issue include:
* Switching Micro-Manager to output OME-TIFF instead of separate images files -- see [here](https://www.micro-manager.org/wiki/Micro-Manager_File_Formats#Image_file_stack_.28in_brief.29)
* Writing a Micro-Manager metadata reader for Bio-Formats that supports the version of Micro-Manager being used by the lab.
  * [The existing metadata reader on Github](https://github.com/openmicroscopy/bioformats/blob/v5.3.0/components/formats-bsd/src/loci/formats/in/MicromanagerReader.java)

## Future work
* Fix the SSH tunneling issue described in "Connecting to OMERO."
* `$PI_SCRATCH` may be subjected to purge policies in the future, meaning that it is not safe to store data there long-term. We need to investigate connecting the Covert lab NAS to Sherlock. The data links in `$PI_HOME/omero` can point to folders on the NAS instead of in `$PI_SCRATCH`.
  * A workaround could be to setup back-up scripts that copy data from `$PI_SCRATCH` to the NAS.
* Investigate better image loading/conversion as described in "Loading images onto OMERO."
* OMERO.web and OMERO.insight experience heavy lag when loading images with many ROIs -- see if increasing server resources helps with this? Doubtful, but worth a shot. To do this, tweak the SBATCH settings in `omero_sherlock.sh`.
* Setup OMERO.dropbox for automated upload of images.
  * [Documentation](https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/dropbox.html)
    * Note that OMERO.dropbox cannot monitor NAS folders, according to the documentation.
* In `share_job.sh`, assumptions about certain ports being open on the login node and ports being used on the compute node are made, which can mean that users cannot connect to OMERO from their local machines if the ports are incorrect. This hasn't been an issue thus far, but is still worth fixing for future sanity, once the above work is complete.
* OMERO can integrate with an existing LDAP authentication system to ease the burden of creating user accounts. Stanford provides an LDAP service -- we should see if it can be useful for the setup on Sherlock.
  * [Stanford LDAP](https://uit.stanford.edu/service/directory)
  * [OMERO LDAP documentation](https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/server-ldap.html)
