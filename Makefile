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

ifeq ($(UNAME), Linux)
RESOURCE_DIR = ".build/debug/Resources"
else
RESOURCE_DIR = ".build/debug/MustachePackageTests.xctest/Contents/Resources"
endif

all: build

build:
	@echo --- Running build on $(UNAME)
	@echo --- Checking swift version
	swift --version
ifeq ($(UNAME), Linux)
	@echo --- Checking Linux release
	-lsb_release -d
	@echo --- Fetching dependencies
	swift package fetch
endif
	@echo --- Invoking swift build
	swift build $(CC_FLAGS) $(SWIFTC_FLAGS) $(LINKER_FLAGS)

test: copytestresources
	@echo --- Invoking swift test
	swift test

refetch:
	@echo --- Removing Packages directory
	rm -rf Packages
	@echo --- Fetching dependencies
	swift package fetch

update:
	@echo --- Updating dependencies
	swift package update

clean:
	@echo --- Invoking swift build --clean
	swift build --clean

Tests/vendor/groue/GRMustacheSpec/Tests:
	@echo --- Fetching GRMustacheSpec
	git submodule init
	git submodule update


copytestresources: Tests/vendor/groue/GRMustacheSpec/Tests
	@echo --- Copying test files
	mkdir -p ${RESOURCE_DIR}
	cp Tests/MustacheTests/*/*.mustache ${RESOURCE_DIR}
	cp Tests/MustacheTests/*/*/*.mustache ${RESOURCE_DIR}
	cp Tests/MustacheTests/*/*/*.text ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/SuitesTests/twitter/hogan.js/HoganSuite ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTests_partial ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/TemplateRepositoryTests/TemplateRepositoryBundleTests/TemplateRepositoryBundleTestsResources ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/ServicesTests/LocalizerTestsBundle ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/TemplateRepositoryTests/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests ${RESOURCE_DIR}
	cp -r Tests/MustacheTests/TemplateRepositoryTests/TemplateRepositoryFileSystemTests/TemplateRepositoryFileSystemTests_* ${RESOURCE_DIR}
	cp -r Tests/vendor/groue/GRMustacheSpec/Tests ${RESOURCE_DIR}

.PHONY: clean build refetch run test
