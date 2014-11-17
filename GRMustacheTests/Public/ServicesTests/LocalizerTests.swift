//
//  LocalizerTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 17/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class LocalizerTests: XCTestCase {
    
    var localizableBundle: NSBundle! = nil
    var localizer: Localizer! = nil

    override func setUp() {
        super.setUp()
        
        let path = NSBundle(forClass: self.dynamicType).pathForResource("LocalizerTestsBundle", ofType: nil)!
        localizableBundle = NSBundle(path: path)
        localizer = Localizer(bundle: localizableBundle, table: nil)
    }
    
    func testLocalizableBundle() {
        let testable = localizableBundle.localizedStringForKey("testable?", value:"", table:nil)
        XCTAssertEqual(testable, "YES")
    }
    
    func testLocalizer() {
        let template = Template(string: "{{localize(string)}}")!
        let value = Value(["localize": Value(localizer as protocol<Filter, TagObserver>), "string": Value("testable?")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "YES")
    }
    
    func testLocalizerFromTable() {
        let template = Template(string: "{{localize(string)}}")!
        let localizer = Localizer(bundle: localizableBundle, table: "Table")
        let value = Value(["localize": Value(localizer), "string": Value("table_testable?")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "YES")
    }

    func testDefaultLocalizerAsFilter() {
        let template = Template(string: "{{localize(foo)}}")!
        let value = Value(["foo": "bar"])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testDefaultLocalizerAsRenderable() {
        let template = Template(string: "{{#localize}}...{{/}}")!
        let rendering = template.render(Value())!
        XCTAssertEqual(rendering, "...")
    }
    
    func testDefaultLocalizerAsRenderableWithArgument() {
        let template = Template(string: "{{#localize}}...{{foo}}...{{/}}")!
        let value = Value(["foo": "bar"])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "...bar...")
    }
    
    func testDefaultLocalizerAsRenderableWithArgumentAndConditions() {
        let template = Template(string: "{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}")!
        let value = Value(["foo": "bar", "baz": "truc"])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, ".bar.truc.")
    }
    
}
