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
        runTestsFromResource("comments", ofType: "json")
        runTestsFromResource("delimiters", ofType: "json")
        runTestsFromResource("general", ofType: "json")
        runTestsFromResource("partials", ofType: "json")
        runTestsFromResource("pragmas", ofType: "json")
        runTestsFromResource("sections", ofType: "json")
        runTestsFromResource("inverted_sections", ofType: "json")
        runTestsFromResource("text_rendering", ofType: "json")
        runTestsFromResource("variables", ofType: "json")
        
        // Errors
        runTestsFromResource("expression_parsing_errors", ofType: "json")
        runTestsFromResource("tag_parsing_errors", ofType: "json")
        
        // Expressions
        runTestsFromResource("compound_keys", ofType: "json")
        runTestsFromResource("filters", ofType: "json")
        runTestsFromResource("implicit_iterator", ofType: "json")
        
        // Inheritance
        runTestsFromResource("blocks", ofType: "json")
        runTestsFromResource("partial_overrides", ofType: "json")
        
        // Standard library
        runTestsFromResource("each", ofType: "json")
        runTestsFromResource("HTMLEscape", ofType: "json")
        runTestsFromResource("javascriptEscape", ofType: "json")
        runTestsFromResource("URLEscape", ofType: "json")
        runTestsFromResource("zip", ofType: "json")
        
        // Values
        runTestsFromResource("array", ofType: "json")
        runTestsFromResource("bool", ofType: "json")
        runTestsFromResource("dictionary", ofType: "json")
        runTestsFromResource("missing_value", ofType: "json")
        runTestsFromResource("null", ofType: "json")
        runTestsFromResource("number", ofType: "json")
        runTestsFromResource("string", ofType: "json")
    }
}
