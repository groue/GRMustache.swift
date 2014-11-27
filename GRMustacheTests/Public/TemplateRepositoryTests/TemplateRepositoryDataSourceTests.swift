//
//  TemplateRepositoryDataSourceTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateRepositoryDataSourceTests: XCTestCase {
    
    func testTemplateRepositoryDataSource() {
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
    
}
