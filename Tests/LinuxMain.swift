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
@testable import MustacheTests

XCTMain([
    testCase(ContextRegisteredKeyTests.allTests),
    testCase(ContextTests.allTests),
    testCase(ContextValueForMustacheExpressionTests.allTests),
    testCase(MustacheBoxTests.allTests),
    testCase(TagTests.allTests),
    testCase(LambdaTests.allTests),
    testCase(BoxTests.allTests),
    testCase(VariadicFilterTests.allTests),
    testCase(FilterTests.allTests),
    testCase(RenderFunctionTests.allTests),
    testCase(TemplateTests.allTests),
    testCase(TemplateFromMethodsTests.allTests),
    testCase(ObjcKeyAccessTests.allTests),
    testCase(GRMustacheSpecTests.allTests),
    testCase(HoganSuite.allTests),
    testCase(LocalizerTests.allTests),
    testCase(LoggerTests.allTests),
    testCase(StandardLibraryTests.allTests),
    testCase(FormatterTests.allTests),
    testCase(EachFilterTests.allTests),
    testCase(HookFunctionTests.allTests),
    testCase(ReadMeTests.allTests),
    testCase(MustacheBoxDocumentationTests.allTests),
    testCase(MustacheRenderableGuideTests.allTests),
    testCase(KeyedSubscriptFunctionTests.allTests),
    testCase(FoundationCollectionTests.allTests),
    testCase(TemplateRepositoryTests.allTests),
    testCase(TemplateRepositoryDataSourceTests.allTests),
    testCase(TemplateRepositoryPathTests.allTests),
    testCase(TemplateRepositoryURLTests.allTests),
    testCase(TemplateRepositoryBundleTests.allTests),
    testCase(TemplateRepositoryDictionaryTests.allTests),
    testCase(ConfigurationTagDelimitersTests.allTests),
    testCase(ConfigurationContentTypeTests.allTests),
    testCase(ConfigurationExtendBaseContextTests.allTests),
    testCase(ConfigurationBaseContextTests.allTests),
])
