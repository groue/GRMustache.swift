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

class FilterTests: XCTestCase {
    
    func testFilterCanChain() {
        let box = Box([
            "name": Box("Name"),
            "uppercase": Box(Filter { (string: String?, error: NSErrorPointer) -> MustacheBox? in
                return Box(string?.uppercaseString)
            }),
            "prefix": Box(Filter { (string: String?, error: NSErrorPointer) -> MustacheBox? in
                return Box("prefix\(string!)")
            })
            ])
        let template = Template(string:"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>")
    }
    
    func testScopedValueAreExtractedOutOfAFilterExpression() {
        let template = Template(string:"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}")!
        var box: MustacheBox
        var rendering: String
        
        box = Box([
            "object": Box(["name": "objectName"]),
            "name": Box("rootName"),
            "f": Box(Filter { (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
                return box
            })
            ])
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<objectName> <objectName>")
        
        box = Box([
            "object": Box(["name": "objectName"]),
            "name": Box("rootName"),
            "f": Box(Filter { (_: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
                return Box(["name": "filterName"])
            })
            ])
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<filterName> <filterName>")
        
        box = Box([
            "object": Box(["name": "objectName"]),
            "name": Box("rootName"),
            "f": Box(Filter { (_: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
                return Box(true)
            })
            ])
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<> <rootName>")
    }
    
    func testFilterArgumentsDoNotEnterSectionContextStack() {
        let box = Box([
            "test": Box("success"),
            "filtered": Box(["test": "failure"]),
            "filter": Box(Filter { (_: MustacheBox, _: NSErrorPointer) -> MustacheBox? in
                return Box(true)
            })])
        let template = Template(string:"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<success instead of failure>")
    }
    
    func testFilterNameSpace() {
        let doubleFilter = Box(Filter { (x: Int?, error: NSErrorPointer) -> MustacheBox? in
            return Box((x ?? 0) * 2)
        })
        let box = Box([
            "x": Box(1),
            "math": Box(["double": doubleFilter])
            ])
        let template = Template(string:"{{ math.double(x) }}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "2")
    }
    
    func testFilterCanReturnFilter() {
        let filterValue = Box(Filter { (string1: String?, error: NSErrorPointer) -> MustacheBox? in
            return Box(Filter { (string2: String?, error: NSErrorPointer) -> MustacheBox? in
                    return Box("\(string1!)\(string2!)")
                })
            })
        let box = Box([
            "prefix": Box("prefix"),
            "value": Box("value"),
            "f": filterValue])
        let template = Template(string:"{{f(prefix)(value)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "prefixvalue")
    }
    
    func testImplicitIteratorCanReturnFilter() {
        let box = Box(Filter { (_: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
            return Box("filter")
        })
        let template = Template(string:"{{.(a)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "filter")
    }
    
    func testMissingFilterError() {
        let box = Box([
            "name": Box("Name"),
            "replace": Box(Filter { (_: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
                return Box("replace")
            })
        ])
        
        var template = Template(string:"<{{missing(missing)}}>")!
        var error: NSError?
        var rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{missing(name)}}>")!
        rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{replace(missing(name))}}>")!
        rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{missing(replace(name))}}>")!
        rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testNotAFilterError() {
        let box = Box([
            "name": "Name",
            "filter": "filter"
            ])
        
        var template = Template(string:"<{{filter(name)}}>")!
        var error: NSError?
        var rendering = template.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsLineNumber() {
        let template = Template(string: "\n{{f(x)}}")!
        var error: NSError?
        let rendering = template.render(error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("Missing filter") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsLineNumber() {
        let template = Template(string: "\n{{f(x)}}")!
        var error: NSError?
        let rendering = template.render(Box(["f": "foo"]), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("Not a filter") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
    
    func testFilterOfOptionalInt() {
        let square = Filter { (x: Int?, error: NSErrorPointer) in
            if let x = x {
                return Box(x * x)
            } else {
                return Box("Nil")
            }
        }
        let template = Template(string: "{{square(x)}}")!
        template.registerInBaseContext("square", Box(square))
        
        var rendering = template.render(Box(["x": 10]))
        XCTAssertEqual(rendering!, "100")
        
        rendering = template.render(Box())
        XCTAssertEqual(rendering!, "Nil")
        
        rendering = template.render(Box(["x": NSNull()]))
        XCTAssertEqual(rendering!, "Nil")
        
        rendering = template.render(Box(["x": "foo"]))
        XCTAssertEqual(rendering!, "Nil")
    }
    
    func testFilterOfOptionalString() {
        let twice = Filter { (x: String?, error: NSErrorPointer) in
            if let x = x {
                return Box(x + x)
            } else {
                return Box("Nil")
            }
        }
        let template = Template(string: "{{twice(x)}}")!
        template.registerInBaseContext("twice", Box(twice))
        
        var rendering = template.render(Box(["x": "A"]))
        XCTAssertEqual(rendering!, "AA")
        
        rendering = template.render(Box(["x": "A" as NSString]))
        XCTAssertEqual(rendering!, "AA")
        
        rendering = template.render(Box())
        XCTAssertEqual(rendering!, "Nil")
        
        rendering = template.render(Box(["x": NSNull()]))
        XCTAssertEqual(rendering!, "Nil")
        
        rendering = template.render(Box(["x": 1]))
        XCTAssertEqual(rendering!, "Nil")
    }
    
    // TODO: import ValueTests.testCustomValueFilter(): testFilterOfOptionalXXX, testFilterOfXXX, etc. for all supported types
}
