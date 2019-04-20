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

class FormatterTests: XCTestCase {
    
    func testFormatterIsAFilterForProcessableValues() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // test that number is processable
        XCTAssertEqual(percentFormatter.string(from: 0.5)!, "50%")

        // test filtering a number
        let template = try! Template(string: "{{ percent(number) }}")
        let value: [String: Any] = ["number": 0.5, "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "50%")
    }
    
    func testFormatterIsAFilterForUnprocessableValues() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // test that number is processable
        XCTAssertTrue(percentFormatter.string(for: "foo") == nil)
        
        // test filtering a string
        let template = try! Template(string: "{{ percent(string) }}")
        let value: [String: Any] = ["string": "foo", "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "")
    }
    
    func testFormatterSectionFormatsInnerVariableTags() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let template = try! Template(string: "{{# percent }}{{ number }} {{ number }}{{/ percent }}")
        let value: [String: Any] = ["number": 0.5, "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "50% 50%")
    }
    
    func testFormatterSectionDoesNotFormatUnprocessableInnerVariableTags() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let template = try! Template(string: "{{# percent }}{{ value }}{{/ percent }}")
        let value: [String: Any] = ["value": "foo", "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "foo")
    }
    
    func testFormatterAsSectionFormatsDeepInnerVariableTags() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let template = try! Template(string: "{{# percent }}{{# number }}Number is {{ number }}.{{/ number }}{{/ percent }}")
        let value: [String: Any] = ["number": 0.5, "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "Number is 50%.")
    }
    
    func testFormatterAsSectionDoesNotFormatInnerSectionTags() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let template = try! Template(string: "NO is {{ NO }}. {{^ NO }}NO is false.{{/ NO }} percent(NO) is {{ percent(NO) }}. {{# percent(NO) }}percent(NO) is true.{{/ percent(NO) }} {{# percent }}{{^ NO }}NO is now {{ NO }} and is still false.{{/ NO }}{{/ percent }}")
        let value: [String: Any] = ["number": 0.5, "NO": 0, "percent": percentFormatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO is 0. NO is false. percent(NO) is 0%. percent(NO) is true. NO is now 0% and is still false.")
    }
    
    func testFormatterIsTruthy() {
        let formatter = Formatter()
        let template = try! Template(string: "{{# formatter }}Formatter is true.{{/ formatter }}{{^ formatter }}Formatter is false.{{/ formatter }}")
        let value = ["formatter": formatter]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "Formatter is true.")
    }
    
    func testFormatterRendersSelfAsSomething() {
        let formatter = Formatter()
        let template = try! Template(string: "{{ formatter }}")
        let value = ["formatter": formatter]
        let rendering = try! template.render(value)
        XCTAssertTrue(rendering.count > 0)
    }
    
    func testNumberFormatterRendersNothingForMissingValue() {
        // Check that NSNumberFormatter does not have surprising behavior, and
        // does not format nil.
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let value = ["format": percentFormatter]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSNull() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let value: [String: Any] = ["format": percentFormatter, "value": NSNull()]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSString() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var value: [String: Any] = ["format": percentFormatter, "value": "1"]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
        
        value = ["format": percentFormatter, "value": "YES"]
        
        template = try! Template(string: "<{{format(value)}}>")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
        
        value = ["format": percentFormatter, "value": "foo"]
        
        template = try! Template(string: "<{{format(value)}}>")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSDate() {
        // Check that NSNumberFormatter does not have surprising behavior, and
        // does not format NSDate.
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let value: [String: Any] = ["format": percentFormatter, "value": Date()]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForMissingValue() {
        // Check that NSDateFormatter does not have surprising behavior, and
        // does not format nil.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        let value = ["format": dateFormatter]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSNull() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        let value: [String: Any] = ["format": dateFormatter, "value": NSNull()]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        var value: [String: Any] = ["format": dateFormatter, "value": "1"]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
        
        value = ["format": dateFormatter, "value": "YES"]
        
        template = try! Template(string: "<{{format(value)}}>")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
        
        value = ["format": dateFormatter, "value": "foo"]
        
        template = try! Template(string: "<{{format(value)}}>")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSNumber() {
        // Check that NSDateFormatter does not have surprising behavior, and
        // does not format NSNumber.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        let value: [String: Any] = ["format": dateFormatter, "value": 0]
        
        var template = try! Template(string: "<{{format(value)}}>")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<>")
        
        template = try! Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "NO")
    }
}
