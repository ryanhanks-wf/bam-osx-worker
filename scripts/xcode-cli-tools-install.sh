#!/bin/sh

# Get Xcode CLI tools
TOOLS=clitools.dmg
DMGURL=https://s3.amazonaws.com/pse-downloads/installers/xcode_6.1.1_commandline_tools.dmg

echo "Installing Xcode Command Line Tools..."

if [ ! -f "$TOOLS" ]; then
  curl "$DMGURL" -o "$TOOLS"
fi

TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
hdiutil detach "$TMPMOUNT"
rm -rf "$TMPMOUNT"
rm "$TOOLS"
exit