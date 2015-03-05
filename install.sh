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

# Colors
NO_COLOR='\e[0m'
EBLACK='\e[1;30m'
ERED='\e[1;31m'
EGREEN='\e[1;32m'
EYELLOW='\e[1;33m'
EBLUE='\e[1;34m'
EWHITE='\e[1;37m'

# Configuration
SOLOIST_DIR="${HOME}/src/pub/soloist"

# Functions
function pause(){
   read -p "$*"
}

function errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}


# Xcode interactive/automated installation
if [ ! -d "/Applications/Xcode.app" ]; then

  	printf "Step 1: $EREDXcode$NO_COLOR must be installed to run Pivotal Sprout Wrap.\n"
	printf "When prompted be sure to click the $EYELLOW'Install'$NO_COLOR button that pops up\n"
	pause 'Press [Enter] key to start the $EREDXcode$NO_COLOR installation...'

	# Force the Yosemite prompt for the installation of Xcode
	git --version

	# Or, alt auto install (more testing needed): 
	# curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/scripts/xcode-install.sh | sudo bash

	printf "\n\nOnce the Xcode installation is complete.\n"
	pause 'Press [Enter] key to continue and install the Xcode Command Line Tools...'

	# Xcode CLI interactive/automated installation
  	printf "Step 2: $EGREENXcode Command Line Tools$NO_COLOR must be installed to run Pivotal Sprout Wrap.\n"
	printf "When prompted be sure to click the $EYELLOW'Install'$NO_COLOR button that pops up\n"
	pause 'Press [Enter] key to start the Xcode Command Line Tools installation...'
	
	# Force the Yosemite prompt for the installation of the Xcode Command Line Tools
	xcode-select --install

	# Or, alt auto install (more testing needed): 
	# curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/scripts/xcode-cli-tools-install.sh | sudo bash

	printf "\n\nOnce the $EGREENXcode Command Line Tools$NO_COLOR installation is complete.\n"
	pause 'Press [Enter] key to continue the Sprout Wrap installation...'

fi


echo "Please enter your sudo password to make changes to your machine"
sudo echo ''

# Xcode license acceptance
curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/scripts/accept-xcode-license.exp > accept-xcode-license.exp

# We need to accept the xcodebuild license agreement before building anything works
if [ -x "$(which expect)" ]; then
  echo "\x1b[31;1mBy using this script, you automatically accept the Xcode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf\x1b[0m"
  expect ./accept-xcode-license.exp
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi


echo "Please enter your sudo password to make changes to your machine"
sudo echo ''

# Special Ruby handling req'd on a new Yosemite installation, otherwise nokogiri will fail to install
printf "Updating Ruby...\n\n"
sudo gem update --system
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# gem uninstall nokogiri
# gem install nokogiri

# Sprout Wrap installation
mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

printf "Checking out Sprout Wrap...\n\n"
if [ -d sprout-wrap-pivotal ]; then
  pushd sprout-wrap-pivotal && git pull
else
  git clone https://github.com/pivotalservices/sprout-wrap-pivotal.git
  pushd sprout-wrap-pivotal
fi

# Setup the local .bashrc and tooling
# Dotfiles are maintained in the ~/bin/dotfiles directory of scripts
printf "Setting up bash and tooling...\n\n"
pwd
cp -r bin ~/
printf ". ~/bin/dotfiles/bashrc" >> ~/.bashrc 
printf ". ~/bin/dotfiles/zshrc" >> ~/.zshrc
mkdir -p ~/.ssh
ln -s ~/bin/dotfiles/ssh/config ~/.ssh/config

# Run Sprout Wrap
printf "Running Sprout Wrap...\n\n"
rvm --version 2>/dev/null
[ ! -x "$(which gem)" -a "$?" -eq 0 ] || USE_SUDO='sudo'

$USE_SUDO gem install bundler
if ! bundle check 2>&1 >/dev/null; then $USE_SUDO bundle install --without development ; fi

export rvm_user_install_flag=1
export rvm_prefix="$HOME"
export rvm_path="${rvm_prefix}/.rvm"

# Now we provision with chef
soloist || errorout "Soloist provisioning failed!"

