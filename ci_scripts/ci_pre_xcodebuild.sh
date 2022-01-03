 #!/bin/sh

#  ci_pre_xcodebuild.sh
#  Card Tracker
#
#  Created by Michael Rowe on 1/2/22.
#  Copyright © 2022 Michael Rowe. All rights reserved.
#  sample from WWDC to swap icon for beta releases

echo "Pre Xcode Build"

#  if [[ -n $CI_PULL_REQUEST_NUMBER && $CI_XCODEBUILD_ACTION = 'archive']];
#  then
    # echo "Changing To Beta Icon"
    # Here we would put the swap like
    # APP_ICON_PATH=$CI_WORKSPACE/Shared/Assets.xcassets/AppIcon.appiconset

    # Remove existing App Icon
    # rm -rf $APP_ICON_PATH

    # Replace with Beta Icon
    # mv "$CI_WORKSPACE/ci_scripts/AppIcon-Beta.appiconset" $APP_ICON_PATH

#  fi
