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

# Configuration
SOLOIST_DIR="${HOME}/src/pub/soloist"

# Functions
function pause(){
   read -p "$*"
}

function errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}

# Let's get started
pushd `pwd`

echo "Please enter your sudo password to make changes to your machine"
sudo echo ''


# Xcode automated installation
if [ ! -d "/Applications/Xcode.app" ]; then

# DL: https://s3.amazonaws.com/pse-downloads/installers/xcode_6.1.1.dmg
# DL: https://s3.amazonaws.com/pse-downloads/installers/xcode_6.1.1_commandline_tools.dmg

	echo "Xcode and the Xcode command line tools must be installed"
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


# Xcode license acceptance
echo "Please enter your sudo password to make changes to your machine"
sudo echo ''

curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/scripts/accept-xcode-license.exp > accept-xcode-license.exp

# We need to accept the xcodebuild license agreement before building anything works
if [ -x "$(which expect)" ]; then
  echo "By using this script, you automatically accept the Xcode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf"
  expect ./accept-xcode-license.exp
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi



# Sprout wrap installation
mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

echo "Checking out sprout-wrap-pivotal..."
if [ -d sprout-wrap-pivotal ]; then
  pushd sprout-wrap-pivotal && git pull
else
  git clone https://github.com/pivotalservices/sprout-wrap-pivotal.git
  pushd sprout-wrap-pivotal
fi

# Setup the local .bashrc and tooling
# Dotfiles are maintained in the ~/bin/dotfiles directory of scripts
cp -R sprout-wrap-pivotal/bin ~/
printf ". ~/bin/dotfiles/bashrc" >> ~/.bashrc 
printf ". ~/bin/dotfiles/zshrc" >> ~/.zshrc
ln -s ~/bin/dotfiles/ssh/config ~/.ssh/config


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
