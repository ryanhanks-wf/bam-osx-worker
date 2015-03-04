#!/bin/sh

# Get Xcode CLI tools
XCODECLI_DMG=xcode_6.1.1_commandline_tools.dmg
XCODECLI_URL=https://s3.amazonaws.com/pse-downloads/installers/
curl "${XCODE_URL}${XCODE_DMG}" -o "$XCODECLI_DMG"

TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
hdiutil attach "$XCODECLI_DMG" -mountpoint "$TMPMOUNT"
installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
hdiutil detach "$TMPMOUNT"
rm -rf "$TMPMOUNT"
rm "$XCODECLI_DMG"
exit