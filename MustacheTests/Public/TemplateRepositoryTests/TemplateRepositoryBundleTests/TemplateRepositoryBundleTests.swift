//
//  TemplateRepositoryBundleTests.swift
//
//  Created by Gwendal Roué on 27/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

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
    
    func testTemplateRepositoryWithBundleTemplateExtensionEncoding() {
        var error: NSError?
        
        var repo = TemplateRepository(bundle: NSBundle(forClass: self.dynamicType), templateExtension: "text", encoding: NSUTF8StringEncoding)
        
        var template = repo.template(named: "notFound", error: &error)
        XCTAssertNil(template)
        XCTAssertNotNil(error)
        
        template = repo.template(named: "TemplateRepositoryBundleTests")
        var rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests.text TemplateRepositoryBundleTests_partial.text")
        
        template = repo.template(string: "{{>TemplateRepositoryBundleTests}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests.text TemplateRepositoryBundleTests_partial.text")
        
        repo = TemplateRepository(bundle: NSBundle(forClass: self.dynamicType), templateExtension: "", encoding: NSUTF8StringEncoding)
        
        template = repo.template(named: "notFound", error: &error)
        XCTAssertNil(template)
        XCTAssertNotNil(error)
        
        template = repo.template(named: "TemplateRepositoryBundleTests")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests TemplateRepositoryBundleTests_partial")
        
        template = repo.template(string: "{{>TemplateRepositoryBundleTests}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "TemplateRepositoryBundleTests TemplateRepositoryBundleTests_partial")
    }
}
