#!/bin/bash

#/**
#* Copyright IBM Corporation 2016
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#**/

PKG_DIR=.
TESTS_DIR="${PKG_DIR}/Tests"
OUTPUT_FILE=${TESTS_DIR}/LinuxMain.swift 

if ! [ -d "${TESTS_DIR}" ]; then
    echo "The directory containing the tests must be named Tests"
    exit 1
fi

cat << 'EOF' > ${OUTPUT_FILE}
/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
EOF

find ${TESTS_DIR} -maxdepth 1 -mindepth 1 -type d -printf '@testable import %fTestSuite\n' >> ${OUTPUT_FILE}

echo >> ${OUTPUT_FILE}
echo XCTMain\(\[ >> ${OUTPUT_FILE}
for FILE in `find ${TESTS_DIR}/*/ -name "*.swift"`; do
    FILE_NAME=`basename ${FILE}`
    FILE_NAME="${FILE_NAME%.*}"
    echo "    testCase(${FILE_NAME}.allTests)," >> ${OUTPUT_FILE}
done
echo "])" >> ${OUTPUT_FILE}
