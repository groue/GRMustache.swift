#!/bin/bash

#  projectSpecificMustachebuildTests.sh
#  GRMustache.swift
#
#  Created by Vadim Eisenberg on 07/02/2016.
#  Copyright © 2016 IBM. All rights reserved.

cp Tests/Sources/*/*.mustache .build/debug/
cp Tests/Sources/*/*.text .build/debug/
cp -r Tests/vendor/groue/GRMustacheSpec/Tests .build/debug/
cp -r Tests/Sources/TwitterHoganJSTests/HoganSuite .build/debug/
cp -r Tests/Sources/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests .build/debug/
cp -r Tests/Sources/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests_partial .build/debug/
cp -r Tests/Sources/TemplateRepositoryBundleTests/TemplateRepositoryBundleTestsResources .build/debug/
cp -r Tests/Sources/ServicesTests/LocalizerTestsBundle .build/debug/
cp -r Tests/Sources/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests .build/debug/
cp -r Tests/Sources/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests_* .build/debug/
