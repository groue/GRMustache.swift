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

class HoganSuite: SuiteTestCase {
    
    func testSuite() {
        // This suite contains template inheritance tests taken from
        // https://github.com/twitter/hogan.js/blob/master/test/index.js
        runTestsFromResource("template_inheritance.json", directory: "HoganSuite")
    }
    
    func testLambdaExpressionInInheritedTemplateSubsections() {
        // Test "Lambda expression in inherited template subsections" from hogan.js tests

        let lambda = Lambda { return "altered \($0)" }
        let templates = [
            "partial": "{{$section1}}{{#lambda}}parent1{{/lambda}}{{/section1}} - {{$section2}}{{#lambda}}parent2{{/lambda}}{{/section2}}",
            "template": "{{< partial}}{{$section1}}{{#lambda}}child1{{/lambda}}{{/section1}}{{/ partial}}",
        ]
        let repo = TemplateRepository(templates: templates)
        let template = try! repo.template(named: "template")
        let rendering = try! template.render(["lambda": lambda])
        XCTAssertEqual(rendering, "altered child1 - altered parent2")
    }
    
    func testBlah() {
        // Test "Lambda expression in included partial templates" from hogan.js tests
        
        let lambda = Lambda { return "changed \($0)" }
        let templates = [
            "parent": "{{$section}}{{/section}}",
            "partial": "{{$label}}test1{{/label}}",
            "template": "{{< parent}}{{$section}}{{<partial}}{{$label}}{{#lambda}}test2{{/lambda}}{{/label}}{{/partial}}{{/section}}{{/parent}}",
        ]
        let repo = TemplateRepository(templates: templates)
        let template = try! repo.template(named: "template")
        let rendering = try! template.render(["lambda": lambda])
        XCTAssertEqual(rendering, "changed test2")
    }
}
