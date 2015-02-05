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
    
    func testTemplateRepositoryWithoutDataSourceCanNotLoadPartialTemplate() {
        let repo = TemplateRepository()
        
        var error: NSError? = nil
        var template = repo.template(named:"partial", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeTemplateNotFound)
        
        error = nil
        template = repo.template(string:"{{>partial}}", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeTemplateNotFound)
    }

    func testTemplateRepositoryWithoutDataSourceCanLoadStringTemplate() {
        let repo = TemplateRepository()
        let template = repo.template(string:"{{.}}")!
        let rendering = template.render(Box("success"))!
        XCTAssertEqual(rendering, "success")
    }
    
    func testTemplateInstancesAreNotReused() {
        let templates = ["name": "value: {{ value }}"]
        let repo = TemplateRepository(templates: templates)
        
        let template1 = repo.template(named: "name")!
        template1.extendBaseContext(Box(["value": "foo"]))
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
        
}
