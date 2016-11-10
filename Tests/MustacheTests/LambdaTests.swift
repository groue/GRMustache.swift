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

class LambdaTests: XCTestCase {

    func testMustacheSpecInterpolation() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L15
        let lambda = Lambda { "world" }
        let template = try! Template(string: "Hello, {{lambda}}!")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "Hello, world!")
    }
    
    func testMustacheSpecInterpolationExpansion() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L29
        let lambda = Lambda { "{{planet}}" }
        let template = try! Template(string: "Hello, {{lambda}}!")
        let data: [String: Any] = [
            "planet": "world",
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "Hello, world!")
    }
    
    func testMustacheSpecInterpolationAlternateDelimiters() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L44
        // With a difference: remove the "\n" character because GRMustache does
        // not honor mustache spec white space rules.
        let lambda = Lambda { "|planet| => {{planet}}" }
        let template = try! Template(string: "{{= | | =}}Hello, (|&lambda|)!")
        let data: [String: Any] = [
            "planet": "world",
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "Hello, (|planet| => world)!")
    }
    
    func testMustacheSpecMultipleCalls() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L59
        var calls = 0
        let lambda = Lambda { calls += 1; return "\(calls)" }
        let template = try! Template(string: "{{lambda}} == {{{lambda}}} == {{lambda}}")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "1 == 2 == 3")
    }
    
    func testMustacheSpecEscaping() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L73
        let lambda = Lambda { ">" }
        let template = try! Template(string: "<{{lambda}}{{{lambda}}}")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "<&gt;>")
    }
    
    func testMustacheSpecSection() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L87
        let lambda = Lambda { (string: String) in
            if string == "{{x}}" {
                return "yes"
            } else {
                return "no"
            }
        }
        let template = try! Template(string: "<{{#lambda}}{{x}}{{/lambda}}>")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "<yes>")
    }
    
    func testMustacheSpecSectionExpansion() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L102
        let lambda = Lambda { (string: String) in
            return "\(string){{planet}}\(string)"
        }
        let template = try! Template(string: "<{{#lambda}}-{{/lambda}}>")
        let data: [String: Any] = [
            "planet": "Earth",
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "<-Earth->")
    }
    
    func testMustacheSpecSectionAlternateDelimiters() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L117
        let lambda = Lambda { (string: String) in
            return "\(string){{planet}} => |planet|\(string)"
        }
        let template = try! Template(string: "{{= | | =}}<|#lambda|-|/lambda|>")
        let data: [String: Any] = [
            "planet": "Earth",
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "<-{{planet}} => Earth->")
    }
    
    func testMustacheSpecSectionMultipleCalls() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L132
        let lambda = Lambda { (string: String) in
            return  "__\(string)__"
        }
        let template = try! Template(string: "{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "__FILE__ != __LINE__")
    }
    
    func testMustacheSpecInvertedSection() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L146
        let lambda = Lambda { (string: String) in
            return  ""
        }
        let template = try! Template(string: "<{{^lambda}}{{static}}{{/lambda}}>")
        let data = [
            "lambda": lambda,
        ]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "<>")
    }
    
    func testPartialInArity0Lambda() {
        // Lambda can't render partials
        let partials = ["partial" : "success"]
        let templateRepository = TemplateRepository(templates: partials)
        let lambda = Lambda { "{{>partial}}" }
        let template = try! templateRepository.template(string: "<{{lambda}}>")
        let data = [
            "lambda": lambda,
        ]
        do {
            _ = try template.render(data)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testPartialInArity1Lambda() {
        // Lambda can't render partials
        let partials = ["partial" : "success"]
        let templateRepository = TemplateRepository(templates: partials)
        let lambda = Lambda { (string: String) in "{{>partial}}" }
        let template = try! templateRepository.template(string: "<{{#lambda}}...{{/lambda}}>")
        let data = [
            "lambda": lambda,
        ]
        do {
            _ = try template.render(data)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testArity0LambdaInSectionTag() {
        let lambda = Lambda { "success" }
        let template = try! Template(string: "{{#lambda}}<{{.}}>{{/lambda}}")
        let rendering = try! template.render(["lambda": lambda])
        XCTAssertEqual(rendering, "<success>")
    }
    
    func testArity1LambdaInVariableTag() {
        let lambda = Lambda { (string) in string }
        let template = try! Template(string: "<{{lambda}}>")
        let rendering = try! template.render(["lambda": lambda])
        XCTAssertEqual(rendering, "<(Lambda)>")
    }
}
