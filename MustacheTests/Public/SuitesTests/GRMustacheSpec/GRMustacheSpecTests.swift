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

class GRMustacheSpecTests: SuiteTestCase {
    
    func testSuite() {
        runTestsFromResource("arrays.json", directory: "Tests")
        runTestsFromResource("comments.json", directory: "Tests")
        runTestsFromResource("compound_keys.json", directory: "Tests")
        runTestsFromResource("delimiters.json", directory: "Tests")
        runTestsFromResource("expression_parsing_errors.json", directory: "Tests")
        runTestsFromResource("filters.json", directory: "Tests")
        runTestsFromResource("general.json", directory: "Tests")
        runTestsFromResource("implicit_iterator.json", directory: "Tests")
        runTestsFromResource("partial_overrides.json", directory: "Tests")
        runTestsFromResource("blocks.json", directory: "Tests")
        runTestsFromResource("inverted_sections.json", directory: "Tests")
        runTestsFromResource("partials.json", directory: "Tests")
        runTestsFromResource("pragmas.json", directory: "Tests")
        runTestsFromResource("sections.json", directory: "Tests")
        runTestsFromResource("standard_library.json", directory: "Tests")
        runTestsFromResource("tag_parsing_errors.json", directory: "Tests")
        runTestsFromResource("text_rendering.json", directory: "Tests")
        runTestsFromResource("variables.json", directory: "Tests")
    }
}
