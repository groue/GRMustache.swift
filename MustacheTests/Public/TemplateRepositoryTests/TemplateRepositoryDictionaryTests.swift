//
//  TemplateRepositoryDictionaryTests.swift
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class TemplateRepositoryDictionaryTests: XCTestCase {

    func testTemplateRepositoryWithDictionary() {
        let templates = [
            "a": "A{{>b}}",
            "b": "B{{>c}}",
            "c": "C"]
        let repo = TemplateRepository(templates: templates)
        
        var error: NSError?
        var template = repo.template(named: "not_found", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, cheErrorDomain)
        XCTAssertEqual(error!.code, cheErrorCodeTemplateNotFound)
        
        template = repo.template(string: "{{>not_found}}", error: &error)
        XCTAssertNil(template)
        XCTAssertEqual(error!.domain, cheErrorDomain)
        XCTAssertEqual(error!.code, cheErrorCodeTemplateNotFound)

        template = repo.template(named: "a")
        var rendering = template!.render()!
        XCTAssertEqual(rendering, "ABC")
        
        template = repo.template(string: "{{>a}}")
        rendering = template!.render()!
        XCTAssertEqual(rendering, "ABC")
    }
    
    func testTemplateRepositoryWithDictionaryIgnoresDictionaryMutation() {
        // This behavior is different from objective-C che.
        //
        // Here we basically test that String and Dictionary are Swift structs,
        // i.e., copied when stored in another object. Mutating the original
        // object has no effect on the stored copy.
        
        var templateString = "foo"
        var templates = ["a": templateString]
        
        let repo = TemplateRepository(templates: templates)
        
        templateString += "{{> bar }}"
        templates["bar"] = "bar"
        
        let template = repo.template(named: "a")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "foo")
    }
    
}
