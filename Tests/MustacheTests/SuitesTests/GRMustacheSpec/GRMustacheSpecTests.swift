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

    static var allTests : [(String, (GRMustacheSpecTests) -> () throws -> Void)] {
        return [
            ("testSuite", testSuite),
        ]
    }

    func testSuite() {
        // General
        runTests(fromResource: "comments.json", directory: "Tests/general")
        runTests(fromResource: "delimiters.json", directory: "Tests/general")
        runTests(fromResource: "general.json", directory: "Tests/general")
        runTests(fromResource: "partials.json", directory: "Tests/general")
        runTests(fromResource: "pragmas.json", directory: "Tests/general")
        runTests(fromResource: "sections.json", directory: "Tests/general")
        runTests(fromResource: "inverted_sections.json", directory: "Tests/general")
        runTests(fromResource: "text_rendering.json", directory: "Tests/general")
        runTests(fromResource: "variables.json", directory: "Tests/general")

        // Errors
        runTests(fromResource: "expression_parsing_errors.json", directory: "Tests/errors")
        runTests(fromResource: "tag_parsing_errors.json", directory: "Tests/errors")

        // Expressions
        runTests(fromResource: "compound_keys.json", directory: "Tests/expressions")
        runTests(fromResource: "filters.json", directory: "Tests/expressions")
        runTests(fromResource: "implicit_iterator.json", directory: "Tests/expressions")

        // Inheritance
        runTests(fromResource: "blocks.json", directory: "Tests/inheritance")
        runTests(fromResource: "partial_overrides.json", directory: "Tests/inheritance")

        // Standard library
        runTests(fromResource: "each.json", directory: "Tests/standard_library")
        runTests(fromResource: "HTMLEscape.json", directory: "Tests/standard_library")
        runTests(fromResource: "javascriptEscape.json", directory: "Tests/standard_library")
        runTests(fromResource: "URLEscape.json", directory: "Tests/standard_library")
        runTests(fromResource: "zip.json", directory: "Tests/standard_library")

        // Values
        runTests(fromResource: "array.json", directory: "Tests/values")
        runTests(fromResource: "bool.json", directory: "Tests/values")
        runTests(fromResource: "dictionary.json", directory: "Tests/values")
        runTests(fromResource: "missing_value.json", directory: "Tests/values")
        runTests(fromResource: "null.json", directory: "Tests/values")
        runTests(fromResource: "number.json", directory: "Tests/values")
        runTests(fromResource: "string.json", directory: "Tests/values")
    }
}
