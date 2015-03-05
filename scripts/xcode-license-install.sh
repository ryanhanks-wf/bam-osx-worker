#!/bin/bash

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