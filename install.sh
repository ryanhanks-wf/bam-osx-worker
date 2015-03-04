#!/bin/bash
#
# This script automates installations on OS X 10.10 Yosemite
#
# Usage:
#   Running the script remotely:
#	  	bash <(curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install.sh)
#   
# 	Running the script if you have downloaded it:
#		./install.sh


function pause(){
   read -p "$*"
}

if [ ! -d "/Applications/Xcode.app" ]; then
	echo "INFO: Xcode and the Xcode command line tools must be installed"
	echo "to run Pivotal Sprout-wrap.  "
	echo " "
	echo "When prompted be sure  to click the 'Get Xcode' button that pops up"
	pause 'Press [Enter] key to start the Xcode installation...'
	echo " "
	echo " "

	# Force the Yosemite prompt for the installation of Xcode and the Xcode command line tools by using git
	git --version

	echo " "
	echo " "
	echo "Once the Xcode installation is complete."
	pause 'Press [Enter] key to start Sprout Wrap installation...'
	echo " "
	echo " "
fi


SOLOIST_DIR="${HOME}/src/pub/soloist"

errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}

pushd `pwd`

mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

echo "INFO: Checking out sprout-wrap-pivotal..."
if [ -d sprout-wrap-pivotal ]; then
  pushd sprout-wrap-pivotal && git pull
else
  git clone https://github.com/pivotalservices/sprout-wrap-pivotal.git
  pushd sprout-wrap-pivotal
fi


echo "Please enter your sudo password to make changes to your machine"
sudo echo ''


rvm --version 2>/dev/null
[ ! -x "$(which gem)" -a "$?" -eq 0 ] || USE_SUDO='sudo'

$USE_SUDO gem install bundler
if ! bundle check 2>&1 >/dev/null; then $USE_SUDO bundle install --without development ; fi

export rvm_user_install_flag=1
export rvm_prefix="$HOME"
export rvm_path="${rvm_prefix}/.rvm"

# Now we provision with chef
soloist || errorout "Soloist provisioning failed!"

echo "Done"
