#!/bin/bash

# Run using:
#
# \curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install-remote.sh | bash

# To enable pausing within the script it is necessary to load then execute the install.sh
SCRIPT=$(curl -s https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/pause.sh)
bash -c "$SCRIPT"