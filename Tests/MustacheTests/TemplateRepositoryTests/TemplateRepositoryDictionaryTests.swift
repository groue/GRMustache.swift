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

class TemplateRepositoryDictionaryTests: XCTestCase {

    func testTemplateRepositoryWithDictionary() {
        let templates = [
            "a": "A{{>b}}",
            "b": "B{{>c}}",
            "c": "C"]
        let repo = TemplateRepository(templates: templates)
        var template: Template
        var rendering: String
        
        do {
            _ = try repo.template(named: "not_found")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            _ = try repo.template(string: "{{>not_found}}")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }

        template = try! repo.template(named: "a")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "ABC")
        
        template = try! repo.template(string: "{{>a}}")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "ABC")
    }
    
    func testTemplateRepositoryWithDictionaryIgnoresDictionaryMutation() {
        // This behavior is different from objective-C GRMustache.
        //
        // Here we basically test that String and Dictionary are Swift structs,
        // i.e., copied when stored in another object. Mutating the original
        // object has no effect on the stored copy.
        
        var templateString = "foo"
        var templates = ["a": templateString]
        
        let repo = TemplateRepository(templates: templates)
        
        templateString += "{{> bar }}"
        templates["bar"] = "bar"
        
        let template = try! repo.template(named: "a")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "foo")
    }
    
}
