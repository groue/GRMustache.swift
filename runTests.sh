#!/bin/bash

#  buildTests.sh
#  Kitura-TestFramework
#
#  Created by Samuel Kallner on 22/12/2015.
#  Copyright © 2015 IBM. All rights reserved.

# If not in the Kitura-TestFramework i was copied from there to ease usage

SCRIPT_DIR=$(dirname "$BASH_SOURCE")
cd "$SCRIPT_DIR"

if [ -f "./mainRunTests.sh" ]; then
    if [ -x "./mainRunTests.sh" ]; then
        ./mainRunTests.sh
    else
        echo "Main test builder script isn't executable"
        exit 1
    fi
else
    fwDir="!"
    for  dir in Packages/Kitura-TestFramework* ; do
        fwDir=$dir
    done
    if [[ "${fwDir}" !=  "!"  &&  -d "${fwDir}" ]]; then
        "${fwDir}/TestFramework/mainRunTests.sh"
    else
        echo "Didn't find the Kitura test framework"
        exit 1
    fi
fi
