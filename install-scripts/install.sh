#!/bin/bash
# Shell script to bootstrap a developer workstation
# Inspired by solowizard.com
#
# Usage:
#   Running the script remotely:
#	  \curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install-scripts/install.sh | bash
#   Running the script if you have downloaded it:
#     ./install.sh
#
# (c) 2012, Tom Hallett
# This script may be freely distributed under the MIT license.

## Figure out OSX version (source: https://www.opscode.com/chef/install.sh)
function detect_platform_version() {
  # Matching the tab-space with sed is error-prone
  platform_version=$(sw_vers | awk '/^ProductVersion:/ { print $2 }')

  major_version=$(echo $platform_version | cut -d. -f1,2)
  
  # x86_64 Apple hardware often runs 32-bit kernels (see OHAI-63)
  x86_64=$(sysctl -n hw.optional.x86_64)
  if [ $x86_64 -eq 1 ]; then
    machine="x86_64"
  fi
}

SOLOIST_DIR="${HOME}/src/pub/soloist"

detect_platform_version

# Determine which XCode version to use based on platform version
case $platform_version in
  "10.9") XCODE_DMG='xcode_6.1.1.dmg' ;;
  *)      XCODE_DMG='xcode_6.1.1.dmg' ;;
esac

errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}

pushd `pwd`

# Bootstrap XCode from dmg
if [ ! -d "/Applications/Xcode.app" ]; then
  echo "INFO: XCode.app not found. Installing XCode..."
  if [ ! -e "$XCODE_DMG" ]; then
    curl -L -O "https://s3.amazonaws.com/pse-downloads/installers/${XCODE_DMG}"
  fi
    
  hdiutil attach "$XCODE_DMG"
  export __CFPREFERENCES_AVOID_DAEMON=1
  sudo installer -pkg '/Volumes/XCode/XCode.pkg' -target /
  hdiutil detach '/Volumes/XCode'
fi

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

curl -Ls https://raw.githubusercontent.com/pivotalservices/sprout-wrap-pivotal/master/install-scripts/xcode-cli-tools.sh | sudo bash

# We need to accept the xcodebuild license agreement before building anything works
if [ -x "$(which expect)" ]; then
  echo "INFO: GNU expect found! By using this script, you automatically accept the XCode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf"
  expect ./bootstrap-scripts/accept-xcodebuild-license.exp
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi


rvm --version 2>/dev/null
[ ! -x "$(which gem)" -a "$?" -eq 0 ] || USE_SUDO='sudo'

$USE_SUDO gem install bundler
if ! bundle check 2>&1 >/dev/null; then $USE_SUDO bundle install --without development ; fi

export rvm_user_install_flag=1
export rvm_prefix="$HOME"
export rvm_path="${rvm_prefix}/.rvm"

# Now we provision with chef
soloist || errorout "Soloist provisioning failed!"
