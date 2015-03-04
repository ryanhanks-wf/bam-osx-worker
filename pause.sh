#!/bin/bash

# \curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/pause.sh | bash


function pause(){
   read -p "$*"
}

echo "Xcode and the Xcode command line tools must be installed"
echo "to run Pivotal Sprout-wrap.  "
echo "When prompted be sure  to click the 'Get Xcode' button that pops up"
pause 'Press [Enter] key to start the Xcode installation...'

# Force the Yosemite prompt for the installation of Xcode and the Xcode command line tools by using git
git --version

echo "Once the Xcode installation is complete."
pause 'Press [Enter] key to start Sprout Wrap installation...'

echo "Done"