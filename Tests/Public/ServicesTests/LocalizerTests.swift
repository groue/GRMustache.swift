// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

class LocalizerTests: XCTestCase {
    
    lazy var localizableBundle: Bundle = Bundle(path: Bundle(for: type(of: self)).path(forResource: "LocalizerTestsBundle", ofType: nil)!)!
    lazy var localizer: StandardLibrary.Localizer = StandardLibrary.Localizer(bundle: self.localizableBundle, table: nil)
    
    func testLocalizableBundle() {
        let testable = localizableBundle.localizedString(forKey: "testable?", value:"", table:nil)
        XCTAssertEqual(testable, "YES")
    }
    
    func testLocalizer() {
        let template = try! Template(string: "{{localize(string)}}")
        let box = Box(["localize": Box(localizer), "string": Box("testable?")])
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "YES")
    }
    
    func testLocalizerFromTable() {
        let template = try! Template(string: "{{localize(string)}}")
        let localizer = StandardLibrary.Localizer(bundle: localizableBundle, table: "Table")
        let box = Box(["localize": Box(localizer), "string": Box("table_testable?")])
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "YES")
    }

    func testLocalizerAsRenderingObjectWithoutArgumentDoesNotNeedPercentEscapedLocalizedString() {
        var template = try! Template(string: "{{#localize}}%d{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = try! template.render()
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "%d", value: nil, table: nil), "ha ha percent d %d")
        XCTAssertEqual(rendering, "ha ha percent d %d")
        
        template = try! Template(string: "{{#localize}}%@{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = try! template.render()
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "%@", value: nil, table: nil), "ha ha percent @ %@")
        XCTAssertEqual(rendering, "ha ha percent @ %@")
    }
    
    func testLocalizerAsRenderingObjectWithoutArgumentNeedsPercentEscapedLocalizedString() {
        var template = try! Template(string: "{{#localize}}%d {{foo}}{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = try! template.render(Box(["foo": "bar"]))
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "%%d %@", value: nil, table: nil), "ha ha percent d %%d %@")
        XCTAssertEqual(rendering, "ha ha percent d %d bar")

        template = try! Template(string: "{{#localize}}%@ {{foo}}{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = try! template.render(Box(["foo": "bar"]))
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "%%@ %@", value: nil, table: nil), "ha ha percent @ %%@ %@")
        XCTAssertEqual(rendering, "ha ha percent @ %@ bar")
    }
    
    func testLocalizerAsFilter() {
        let template = try! Template(string: "{{localize(foo)}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = try! template.render(Box(["foo": "bar"]))
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "bar", value: nil, table: nil), "translated_bar")
        XCTAssertEqual(rendering, "translated_bar")
    }
    
    func testLocalizerAsRenderable() {
        let template = try! Template(string: "{{#localize}}bar{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = try! template.render()
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "bar", value: nil, table: nil), "translated_bar")
        XCTAssertEqual(rendering, "translated_bar")
    }
    
    func testLocalizerAsRenderableWithArgument() {
        let template = try! Template(string: "{{#localize}}..{{foo}}..{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = try! template.render(Box(["foo": "bar"]))
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: "..%@..", value: nil, table: nil), "!!%@!!")
        XCTAssertEqual(rendering, "!!bar!!")
    }
    
    func testLocalizerAsRenderableWithArgumentAndConditions() {
        let template = try! Template(string: "{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        let rendering = try! template.render(Box(["foo": "bar", "baz": "truc"]))
        XCTAssertEqual(self.localizer.bundle.localizedString(forKey: ".%@.%@.", value: nil, table: nil), "!%@!%@!")
        XCTAssertEqual(rendering, "!bar!truc!")
    }
    
    func testLocalizerRendersHTMLEscapedValuesOfHTMLTemplates() {
        var template = try! Template(string: "{{#localize}}..{{foo}}..{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = try! template.render(Box(["foo": "&"]))
        XCTAssertEqual(rendering, "!!&amp;!!")

        template = try! Template(string: "{{#localize}}..{{{foo}}}..{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = try! template.render(Box(["foo": "&"]))
        XCTAssertEqual(rendering, "!!&!!")
    }
    
    func testLocalizerRendersUnescapedValuesOfTextTemplates() {
        var template = try! Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{foo}}..{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        var rendering = try! template.render(Box(["foo": "&"]))
        XCTAssertEqual(rendering, "!!&!!")
        
        template = try! Template(string: "{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{{foo}}}..{{/}}")
        template.baseContext = template.baseContext.extendedContext(Box(["localize": Box(localizer)]))
        rendering = try! template.render(Box(["foo": "&"]))
        XCTAssertEqual(rendering, "!!&!!")
    }
}
