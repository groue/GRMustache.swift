// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

class GRMustacheSuiteTests: SuiteTestCase {
    
    func testSuite() {
        runTestsFromResource("comments.json", directory: "GRMustacheSuite")
        runTestsFromResource("compound_keys.json", directory: "GRMustacheSuite")
        runTestsFromResource("delimiters.json", directory: "GRMustacheSuite")
        runTestsFromResource("expression_parsing_errors.json", directory: "GRMustacheSuite")
        runTestsFromResource("filters.json", directory: "GRMustacheSuite")
        runTestsFromResource("general.json", directory: "GRMustacheSuite")
        runTestsFromResource("implicit_iterator.json", directory: "GRMustacheSuite")
        runTestsFromResource("inheritable_partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("inheritable_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("inverted_sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("partials.json", directory: "GRMustacheSuite")
        runTestsFromResource("pragmas.json", directory: "GRMustacheSuite")
        runTestsFromResource("sections.json", directory: "GRMustacheSuite")
        runTestsFromResource("standard_library.json", directory: "GRMustacheSuite")
        runTestsFromResource("tag_parsing_errors.json", directory: "GRMustacheSuite")
        runTestsFromResource("text_rendering.json", directory: "GRMustacheSuite")
        runTestsFromResource("variables.json", directory: "GRMustacheSuite")
    }
}
