# @File(label='Select a directory containing images to merge', style='directory') image_dir

# Given a directory with microscope images, one for each frame / channel combination,
# this script takes the images from that directory and converts them to a single OME-TIFF file.
#
# Since this script is run in Fiji, Python 2.5 must be used. Fiji uses a Jython interpreter that
# only supports Python 2.5.
#
# Example headless (no UI) usage:
# ./ImageJ-linux64 --ij2 --headless --run ~/fiji_scripts/convert_ome_tiff.py 'image_dir="/home/microscope/scope1dataM/Taka/20160701/run_ef_1/Pos1/"'
#
# More headless info:
# http://imagej.net/Headless
# http://imagej.net/Scripting_Headless

import os
import re
import sys

from ij import IJ
from ij.plugin import RGBStackMerge


image_dir_path = image_dir.getAbsolutePath()
parent_dir_name, dir_name = os.path.split(image_dir_path)
image_files = [os.path.join(image_dir_path, image_path)
			   for image_path in os.listdir(image_dir_path)
			   if image_path != 'metadata.txt']

# Determine the channels and count the number of timepoints
# for each channel.
channels = {}
for image_file in image_files:
	channel = re.search('channel(\d+)_', image_file).group(1)
	if channel in channels:
		channels[channel] += 1
	else:
		channels[channel] = 1

if len(channels) > 7:
	print 'Images with more than 7 channels are not currently supported by the Merge Channels operation.'
	sys.exit(1)

# Open an image sequence for each channel.
stacks = []
for channel in channels:
	num_frames = channels[channel]

	IJ.run('Image Sequence...', 'open=%s file=channel%s sort' % (image_files[0], channel))
	stack = IJ.getImage()
	stack.setTitle(channel)
	stack.setDimensions(1, 1, num_frames)  # TODO Don't hardcode the number of slices
	stacks.append(stack)

merged_image = RGBStackMerge().mergeChannels(stacks, False)
merged_image.setTitle(dir_name)

# TODO Alternatively, we could upload directly to OMERO. But that probably
# would not work in headless mode.
IJ.run(merged_image, 'OME-TIFF...', 'save=%s.ome.tif compression=Uncompressed' % os.path.join(parent_dir_name, dir_name))
