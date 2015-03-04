#!/bin/sh
 
XCODE_URL='https://s3.amazonaws.com/pse-downloads/installers/'
XCODE_DMG='xcode_6.1.1.dmg'

# Get Xcode
if [ ! -d "/Applications/Xcode.app" ]; then
  echo "Installing Xcode..."
  if [ ! -e "$XCODE_DMG" ]; then
    curl -L -O "${XCODE_URL}${XCODE_DMG}"
  fi
    
  hdiutil attach "$XCODE_DMG"
  export __CFPREFERENCES_AVOID_DAEMON=1
  sudo installer -pkg '/Volumes/Xcode/Xcode.pkg' -target /
  hdiutil detach '/Volumes/Xcode'
fi
exit