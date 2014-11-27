//
//  TemplateRepositoryTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateRepositoryTests: XCTestCase {

    func testTemplateInstancesAreNotReused() {
        let templates = ["name": "value: {{ value }}"]
        let repo = TemplateRepository(templates: templates)
        
        let template1 = repo.template(named: "name")!
        template1.extendBaseContext(value: Value(["value": "foo"]))
        let rendering1 = template1.render()!
        
        let template2 = repo.template(named: "name")!
        let rendering2 = template2.render()!
        
        XCTAssertEqual(rendering1, "value: foo")
        XCTAssertEqual(rendering2, "value: ")
    }
    
    func testReloadTemplates() {
        class TestedDataSource: TemplateRepositoryDataSource {
            var templates: [String: String]
            init(templates: [String: String]) {
                self.templates = templates
            }
            func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
                return name
            }
            func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
                return templates[templateID]
            }
            func setTemplateString(templateString: String, forKey key: String) {
                templates[key] = templateString
            }
        }
        
        var templates = [
            "template": "foo{{>partial}}",
            "partial": "bar"]
        var dataSource = TestedDataSource(templates: templates)
        let repo = TemplateRepository(dataSource: dataSource)
        
        var template = repo.template(named: "template")!
        var rendering = template.render()!
        XCTAssertEqual(rendering, "foobar")
        
        dataSource.setTemplateString("baz{{>partial}}", forKey: "template")
        dataSource.setTemplateString("qux", forKey: "partial")
        
        template = repo.template(named: "template")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "foobar")
        
        repo.reloadTemplates()
        
        template = repo.template(named: "template")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "bazqux")
    }
    
    func testDataSource() {
        class TestedDataSource: TemplateRepositoryDataSource {
            func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
                return name
            }
            func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
                switch templateID {
                case "not_found":
                    return nil
                case "error":
                    if error != nil {
                        error.memory = NSError(domain: "TestedDataSource", code: 0, userInfo: nil)
                    }
                    return nil
                default:
                    return templateID
                }
            }
        }
        
        let repo = TemplateRepository(dataSource: TestedDataSource())
        
        var error: NSError?
        var template = repo.template(named: "foo")
        var rendering = template?.render()
        XCTAssertEqual(rendering!, "foo")
        
        template = repo.template(string: "{{>foo}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "foo")
        
        template = repo.template(string: "{{>not_found}}", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeTemplateNotFound)
        
        template = repo.template(string: "{{>error}}", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, "TestedDataSource")
    }
    
    func testTemplateRepositoryWithDictionary() {
        let templates = [
            "a": "A{{>b}}",
            "b": "B{{>c}}",
            "c": "C"]
        let repo = TemplateRepository(templates: templates)
        
        var error: NSError?
        var template = repo.template(named: "not_found", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeTemplateNotFound)
        
        template = repo.template(string: "{{>not_found}}", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeTemplateNotFound)

        template = repo.template(named: "a")
        var rendering = template!.render()!
        XCTAssertEqual(rendering, "ABC")
        
        template = repo.template(string: "{{>a}}")
        rendering = template!.render()!
        XCTAssertEqual(rendering, "ABC")
    }
}
