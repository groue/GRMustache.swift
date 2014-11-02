//
//  GRMustacheTests.swift
//  GRMustacheTests
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation
import XCTest

class GRMustacheTests: XCTestCase {
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

    func testSwiftVariableInterpolation() {
        var error: NSError?
        let repository = MustacheTemplateRepository()
        if let template = repository.templateFromString("<{{name}}>", error: &error) {
            let data = MustacheValue(["name": MustacheValue("Arthur")])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
    
    func testObjCVariableInterpolation() {
        var error: NSError?
        let repository = MustacheTemplateRepository()
        if let template = repository.templateFromString("<{{name}}>", error: &error) {
            let data = MustacheValue(["name": "Arthur"])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
    
    func testPartial() {
        var error: NSError?
        let repository = MustacheTemplateRepository(templates: ["partial": "{{name}}"])
        if let template = repository.templateFromString("<{{>partial}}>", error: &error) {
            let data = MustacheValue(["name": MustacheValue("Arthur")])
            if let rendering = template.render(data, error: &error) {
                XCTAssertEqual(rendering, "<Arthur>", "")
            } else {
                XCTFail("\(error!)")
            }
        } else {
            XCTFail("\(error!)")
        }
    }
}
