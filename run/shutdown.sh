#!/usr/bin/env bash

# Stopping the web and server supervisor programs doesn't actually stop the services --
# we need to stop them using these below commands.
omero web stop
omero admin stop
