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

class TemplateRepositoryTests: XCTestCase {
    
    func testTemplateRepositoryWithoutDataSourceCanNotLoadPartialTemplate() {
        let repo = TemplateRepository()
        
        do {
            _ = try repo.template(named:"partial")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        do {
            _ = try repo.template(string:"{{>partial}}")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }

    func testTemplateRepositoryWithoutDataSourceCanLoadStringTemplate() {
        let repo = TemplateRepository()
        let template = try! repo.template(string:"{{.}}")
        let rendering = try! template.render("success")
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateInstancesAreNotReused() {
        let templates = ["name": "value: {{ value }}"]
        let repo = TemplateRepository(templates: templates)
        
        let template1 = try! repo.template(named: "name")
        template1.register("foo", forKey: "value")
        let rendering1 = try! template1.render()
        
        let template2 = try! repo.template(named: "name")
        let rendering2 = try! template2.render()
        
        XCTAssertEqual(rendering1, "value: foo")
        XCTAssertEqual(rendering2, "value: ")
    }
    
    func testReloadTemplates() {
        class TestedDataSource: TemplateRepositoryDataSource {
            var templates: [String: String]
            init(templates: [String: String]) {
                self.templates = templates
            }
            func templateIDForName(_ name: String, relativeToTemplateID baseTemplateID: TemplateID?) -> TemplateID? {
                return name
            }
            func templateStringForTemplateID(_ templateID: TemplateID) throws -> String {
                if let string = templates[templateID] {
                    return string
                } else {
                    throw MustacheError(kind: .templateNotFound)
                }
            }
            func setTemplateString(_ templateString: String, forKey key: String) {
                templates[key] = templateString
            }
        }
        
        let templates = [
            "template": "foo{{>partial}}",
            "partial": "bar"]
        let dataSource = TestedDataSource(templates: templates)
        let repo = TemplateRepository(dataSource: dataSource)
        
        var template = try! repo.template(named: "template")
        var rendering = try! template.render()
        XCTAssertEqual(rendering, "foobar")
        
        dataSource.setTemplateString("baz{{>partial}}", forKey: "template")
        dataSource.setTemplateString("qux", forKey: "partial")
        
        template = try! repo.template(named: "template")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "foobar")
        
        repo.reloadTemplates()
        
        template = try! repo.template(named: "template")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "bazqux")
    }
        
}
