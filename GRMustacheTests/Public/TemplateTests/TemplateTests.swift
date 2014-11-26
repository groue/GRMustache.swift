//
//  TemplateTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TemplateTests: XCTestCase {
    
    func testTemplatebelongsToItsOriginTemplateRepository() {
        let repo = TemplateRepository()
        let template = repo.template(string:"")!
        XCTAssertTrue(template.repository === repo)
    }
}
