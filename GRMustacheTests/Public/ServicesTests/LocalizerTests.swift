//
//  LocalizerTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 17/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

//class LocalizerTests: XCTestCase {
//    
//    var localizableBundle: NSBundle! = nil
//    var localizer: Localizer! = nil
//
//    override func setUp() {
//        super.setUp()
//        
//        let path = NSBundle(forClass: self.dynamicType).pathForResource("LocalizerTestsBundle", ofType: nil)!
//        localizableBundle = NSBundle(path: path)
//        localizer = Localizer(bundle: localizableBundle, table: nil)
//    }
//    
//    func testLocalizableBundle() {
//        let testable = localizableBundle.localizedStringForKey("testable?", value:"", table:nil)
//        XCTAssertEqual(testable, "YES")
//    }
//    
//    func testLocalizer() {
//        let template = Template(string: "{{localize(string)}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        let value = Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>), "string": Box("testable?")])
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "YES")
//    }
//    
//    func testLocalizerFromTable() {
//        let template = Template(string: "{{localize(string)}}")!
//        let localizer = Localizer(bundle: localizableBundle, table: "Table")
//        let value = Box(["localize": Box(localizer), "string": Box("table_testable?")])
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "YES")
//    }
//
//    func testDefaultLocalizerAsFilter() {
//        let template = Template(string: "{{localize(foo)}}")!
//        let value = Box(["foo": "bar"])
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "bar")
//    }
//    
//    func testDefaultLocalizerAsRenderable() {
//        let template = Template(string: "{{#localize}}...{{/}}")!
//        let rendering = template.render()!
//        XCTAssertEqual(rendering, "...")
//    }
//    
//    func testDefaultLocalizerAsRenderableWithArgument() {
//        let template = Template(string: "{{#localize}}...{{foo}}...{{/}}")!
//        let value = Box(["foo": "bar"])
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "...bar...")
//    }
//    
//    func testDefaultLocalizerAsRenderableWithArgumentAndConditions() {
//        let template = Template(string: "{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}")!
//        let value = Box(["foo": "bar", "baz": "truc"])
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, ".bar.truc.")
//    }
//    
//    func testLocalizerAsRenderingObjectWithoutArgumentDoesNotNeedPercentEscapedLocalizedString() {
//        var template = Template(string: "{{#localize}}%d{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        var rendering = template.render()!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%d", value: nil, table: nil), "ha ha percent d %d")
//        XCTAssertEqual(rendering, "ha ha percent d %d")
//        
//        template = Template(string: "{{#localize}}%@{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        rendering = template.render()!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%@", value: nil, table: nil), "ha ha percent @ %@")
//        XCTAssertEqual(rendering, "ha ha percent @ %@")
//    }
//    
//    func testLocalizerAsRenderingObjectWithoutArgumentNeedsPercentEscapedLocalizedString() {
//        var template = Template(string: "{{#localize}}%d {{foo}}{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        var rendering = template.render(Box(["foo": "bar"]))!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%%d %@", value: nil, table: nil), "ha ha percent d %%d %@")
//        XCTAssertEqual(rendering, "ha ha percent d %d bar")
//
//        template = Template(string: "{{#localize}}%@ {{foo}}{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        rendering = template.render(Box(["foo": "bar"]))!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%%@ %@", value: nil, table: nil), "ha ha percent @ %%@ %@")
//        XCTAssertEqual(rendering, "ha ha percent @ %@ bar")
//    }
//    
//    func testLocalizerAsFilter() {
//        let template = Template(string: "{{localize(foo)}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        let rendering = template.render(Box(["foo": "bar"]))!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("bar", value: nil, table: nil), "translated_bar")
//        XCTAssertEqual(rendering, "translated_bar")
//    }
//    
//    func testLocalizerAsRenderable() {
//        let template = Template(string: "{{#localize}}bar{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        let rendering = template.render()!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("bar", value: nil, table: nil), "translated_bar")
//        XCTAssertEqual(rendering, "translated_bar")
//    }
//    
//    func testLocalizerAsRenderableWithArgument() {
//        let template = Template(string: "{{#localize}}..{{foo}}..{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        let rendering = template.render(Box(["foo": "bar"]))!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("..%@..", value: nil, table: nil), "!!%@!!")
//        XCTAssertEqual(rendering, "!!bar!!")
//    }
//    
//    func testLocalizerAsRenderableWithArgumentAndConditions() {
//        let template = Template(string: "{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}")!
//        // TODO: make this protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver> cast unnecessary
//        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer as protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>)]))
//        let rendering = template.render(Box(["foo": "bar", "baz": "truc"]))!
//        XCTAssertEqual(self.localizer.bundle.localizedStringForKey(".%@.%@.", value: nil, table: nil), "!%@!%@!")
//        XCTAssertEqual(rendering, "!bar!truc!")
//    }
//    
//    func testLocalizerRendersHTMLEscapedValuesOfHTMLTemplates() {
//        var template = Template(string: "{{#localize}}..{{foo}}..{{/}}")!
//        var rendering = template.render(Box(["foo": "&"]))!
//        XCTAssertEqual(rendering, "..&amp;..")
//
//        template = Template(string: "{{#localize}}..{{{foo}}}..{{/}}")!
//        rendering = template.render(Box(["foo": "&"]))!
//        XCTAssertEqual(rendering, "..&..")
//    }
//    
//    func testLocalizerRendersUnescapedValuesOfTextTemplates() {
//        var template = Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{foo}}..{{/}}")!
//        var rendering = template.render(Box(["foo": "&"]))!
//        XCTAssertEqual(rendering, "..&..")
//        
//        template = Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{{foo}}}..{{/}}")!
//        rendering = template.render(Box(["foo": "&"]))!
//        XCTAssertEqual(rendering, "..&..")
//    }
//}
