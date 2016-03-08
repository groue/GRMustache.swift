# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Makefile

UNAME = ${shell uname}

CC_FLAGS =
SWIFTC_FLAGS =
LINKER_FLAGS = 


all: build

build:
	@echo --- Running build on $(UNAME)
	@echo --- Build scripts directory: ${KITURA_CI_BUILD_SCRIPTS_DIR}
	@echo --- Checking swift version
	swift --version
ifeq ($(UNAME), Linux)
	@echo --- Checking Linux release
	-lsb_release -d
	@echo --- Fetching dependencies
	swift build --fetch
endif
	@echo --- Invoking swift build
	swift build $(CC_FLAGS) $(SWIFTC_FLAGS) $(LINKER_FLAGS)

test: build copytestresources
	@echo --- Invoking swift test
	swift test

refetch:
	@echo --- Removing Packages directory
	rm -rf Packages
	@echo --- Fetching dependencies
	swift build --fetch

clean:
	@echo --- Invoking swift build --clean
	swift build --clean

NonSwiftPackageManagerTests/vendor/groue/GRMustacheSpec:
	@echo --- Fetching GRMustacheSpec
	git submodule init
	git submodule update


copytestresources: NonSwiftPackageManagerTests/vendor/groue/GRMustacheSpec
	@echo --- Copying test files
	mkdir -p .build/debug/Package.xctest/Contents/Resources
	cp Tests/Mustache/*/*.mustache .build/debug/Package.xctest/Contents/Resources
	cp Tests/Mustache/*/*/*.mustache .build/debug/Package.xctest/Contents/Resources
	cp Tests/Mustache/*/*/*.text .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/SuitesTests/twitter/hogan.js/HoganSuite .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests_partial .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTestsResources .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/ServicesTests/LocalizerTestsBundle .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/TemplateRepositoryTests/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests .build/debug/Package.xctest/Contents/Resources
	cp -r Tests/Mustache/TemplateRepositoryTests/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests_* .build/debug/Package.xctest/Contents/Resources
	cp -r NonSwiftPackageManagerTests/vendor/groue/GRMustacheSpec/Tests .build/debug/Package.xctest/Contents/Resources

.PHONY: clean build refetch run test 
