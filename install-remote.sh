#!/bin/bash

# Run using:
#
# \curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install-remote.sh | bash -c "$SCRIPT"

# To enable pausing within the script it is necessary to load then execute the install.sh
SCRIPT=$(curl -s https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install.sh)
# bash -c "$SCRIPT"