//
//  LocalizerTests.swift
//
//  Created by Gwendal Roué on 17/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class LocalizerTests: XCTestCase {
    
    lazy var localizableBundle: NSBundle = NSBundle(path: NSBundle(forClass: self.dynamicType).pathForResource("LocalizerTestsBundle", ofType: nil)!)!
    lazy var localizer: StandardLibrary.Localizer = StandardLibrary.Localizer(bundle: self.localizableBundle, table: nil)
    
    func testLocalizableBundle() {
        let testable = localizableBundle.localizedStringForKey("testable?", value:"", table:nil)
        XCTAssertEqual(testable, "YES")
    }
    
    func testLocalizer() {
        let template = Template(string: "{{localize(string)}}")!
        let box = Box(["localize": Box(localizer), "string": Box("testable?")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "YES")
    }
    
    func testLocalizerFromTable() {
        let template = Template(string: "{{localize(string)}}")!
        let localizer = StandardLibrary.Localizer(bundle: localizableBundle, table: "Table")
        let box = Box(["localize": Box(localizer), "string": Box("table_testable?")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "YES")
    }

    func testLocalizerAsRenderingObjectWithoutArgumentDoesNotNeedPercentEscapedLocalizedString() {
        var template = Template(string: "{{#localize}}%d{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = template.render()!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%d", value: nil, table: nil), "ha ha percent d %d")
        XCTAssertEqual(rendering, "ha ha percent d %d")
        
        template = Template(string: "{{#localize}}%@{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = template.render()!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%@", value: nil, table: nil), "ha ha percent @ %@")
        XCTAssertEqual(rendering, "ha ha percent @ %@")
    }
    
    func testLocalizerAsRenderingObjectWithoutArgumentNeedsPercentEscapedLocalizedString() {
        var template = Template(string: "{{#localize}}%d {{foo}}{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = template.render(Box(["foo": "bar"]))!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%%d %@", value: nil, table: nil), "ha ha percent d %%d %@")
        XCTAssertEqual(rendering, "ha ha percent d %d bar")

        template = Template(string: "{{#localize}}%@ {{foo}}{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = template.render(Box(["foo": "bar"]))!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("%%@ %@", value: nil, table: nil), "ha ha percent @ %%@ %@")
        XCTAssertEqual(rendering, "ha ha percent @ %@ bar")
    }
    
    func testLocalizerAsFilter() {
        let template = Template(string: "{{localize(foo)}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = template.render(Box(["foo": "bar"]))!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("bar", value: nil, table: nil), "translated_bar")
        XCTAssertEqual(rendering, "translated_bar")
    }
    
    func testLocalizerAsRenderable() {
        let template = Template(string: "{{#localize}}bar{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = template.render()!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("bar", value: nil, table: nil), "translated_bar")
        XCTAssertEqual(rendering, "translated_bar")
    }
    
    func testLocalizerAsRenderableWithArgument() {
        let template = Template(string: "{{#localize}}..{{foo}}..{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = template.render(Box(["foo": "bar"]))!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey("..%@..", value: nil, table: nil), "!!%@!!")
        XCTAssertEqual(rendering, "!!bar!!")
    }
    
    func testLocalizerAsRenderableWithArgumentAndConditions() {
        let template = Template(string: "{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = template.render(Box(["foo": "bar", "baz": "truc"]))!
        XCTAssertEqual(self.localizer.bundle.localizedStringForKey(".%@.%@.", value: nil, table: nil), "!%@!%@!")
        XCTAssertEqual(rendering, "!bar!truc!")
    }
    
    func testLocalizerRendersHTMLEscapedValuesOfHTMLTemplates() {
        var template = Template(string: "{{#localize}}..{{foo}}..{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = template.render(Box(["foo": "&"]))!
        XCTAssertEqual(rendering, "!!&amp;!!")

        template = Template(string: "{{#localize}}..{{{foo}}}..{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = template.render(Box(["foo": "&"]))!
        XCTAssertEqual(rendering, "!!&!!")
    }
    
    func testLocalizerRendersUnescapedValuesOfTextTemplates() {
        var template = Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{foo}}..{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = template.render(Box(["foo": "&"]))!
        XCTAssertEqual(rendering, "!!&!!")
        
        template = Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{{foo}}}..{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = template.render(Box(["foo": "&"]))!
        XCTAssertEqual(rendering, "!!&!!")
    }
}
