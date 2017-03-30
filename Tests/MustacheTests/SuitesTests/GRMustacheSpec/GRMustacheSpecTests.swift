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
        // General
        runTestsFromResource("comments.json", directory: "Tests/general")
        runTestsFromResource("delimiters.json", directory: "Tests/general")
        runTestsFromResource("general.json", directory: "Tests/general")
        runTestsFromResource("partials.json", directory: "Tests/general")
        runTestsFromResource("pragmas.json", directory: "Tests/general")
        runTestsFromResource("sections.json", directory: "Tests/general")
        runTestsFromResource("inverted_sections.json", directory: "Tests/general")
        runTestsFromResource("text_rendering.json", directory: "Tests/general")
        runTestsFromResource("variables.json", directory: "Tests/general")
        
        // Errors
        runTestsFromResource("expression_parsing_errors.json", directory: "Tests/errors")
        runTestsFromResource("tag_parsing_errors.json", directory: "Tests/errors")
        
        // Expressions
        runTestsFromResource("compound_keys.json", directory: "Tests/expressions")
        runTestsFromResource("filters.json", directory: "Tests/expressions")
        runTestsFromResource("implicit_iterator.json", directory: "Tests/expressions")
        
        // Inheritance
        runTestsFromResource("blocks.json", directory: "Tests/inheritance")
        runTestsFromResource("partial_overrides.json", directory: "Tests/inheritance")
        
        // Standard library
        runTestsFromResource("each.json", directory: "Tests/standard_library")
        runTestsFromResource("HTMLEscape.json", directory: "Tests/standard_library")
        runTestsFromResource("javascriptEscape.json", directory: "Tests/standard_library")
        runTestsFromResource("URLEscape.json", directory: "Tests/standard_library")
        runTestsFromResource("zip.json", directory: "Tests/standard_library")
        
        // Values
        runTestsFromResource("array.json", directory: "Tests/values")
        runTestsFromResource("bool.json", directory: "Tests/values")
        runTestsFromResource("dictionary.json", directory: "Tests/values")
        runTestsFromResource("missing_value.json", directory: "Tests/values")
        runTestsFromResource("null.json", directory: "Tests/values")
        runTestsFromResource("number.json", directory: "Tests/values")
        runTestsFromResource("string.json", directory: "Tests/values")
    }
}
