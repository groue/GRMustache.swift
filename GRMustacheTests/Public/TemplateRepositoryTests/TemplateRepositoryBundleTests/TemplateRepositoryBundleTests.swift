//
//  TemplateRepositoryBundleTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 27/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateRepositoryBundleTests: XCTestCase {
    
    func testTemplateRepositoryWithBundle() {
        let repo = TemplateRepository(bundle: NSBundle(forClass: self.dynamicType))
        
        var error: NSError?
        var template = repo.template(named: "notFound", error: &error)
        XCTAssertNil(template)
        XCTAssertNotNil(error)
        
        template = repo.template(named: "TemplateRepositoryBundleTests")
        var rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests.mustache TemplateRepositoryBundleTests_partial.mustache")
        
        template = repo.template(string: "{{>TemplateRepositoryBundleTests}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests.mustache TemplateRepositoryBundleTests_partial.mustache")
        
        template = repo.template(string: "{{>TemplateRepositoryBundleTestsResources/partial}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "partial sibling TemplateRepositoryBundleTests.mustache TemplateRepositoryBundleTests_partial.mustache")
    }
}
