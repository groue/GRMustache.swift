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
    
    enum CustomError : Error {
        case error
    }
    
    func testFilterCanChain() {
        let value: [String: Any] = [
            "name": "Name",
            "uppercase": Filter { (string: String?) in
                return string?.uppercased()
            },
            "prefix": Filter { (string: String?) in
                return "prefix\(string!)"
            }
            ]
        let template = try! Template(string:"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>")
    }
    
    func testScopedValueAreExtractedOutOfAFilterExpression() {
        let template = try! Template(string:"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}")
        var value: [String: Any]
        var rendering: String
        
        value = [
            "object": ["name": "objectName"],
            "name": "rootName",
            "f": Filter { (box: MustacheBox) in box }
            ]
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<objectName> <objectName>")
        
        value = [
            "object": ["name": "objectName"],
            "name": "rootName",
            "f": Filter { _ in ["name": "filterName"] }
            ]
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<filterName> <filterName>")
        
        value = [
            "object": ["name": "objectName"],
            "name": "rootName",
            "f": Filter { _ in true }
            ]
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<> <rootName>")
    }
    
    func testFilterArgumentsDoNotEnterSectionContextStack() {
        let value: [String: Any] = [
            "test": "success",
            "filtered": ["test": "failure"],
            "filter": Filter { (_: MustacheBox) in true }
        ]
        let template = try! Template(string:"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<success instead of failure>")
    }
    
    func testFilterNameSpace() {
        let doubleFilter = Filter { (x: Int?) in
            return (x ?? 0) * 2
        }
        let value: [String: Any] = [
            "x": 1,
            "math": ["double": doubleFilter]
            ]
        let template = try! Template(string:"{{ math.double(x) }}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "2")
    }
    
    func testFilterCanReturnFilter() {
        let filterValue = Filter { (string1: String?) in
            return Filter { (string2: String?) in
                    return "\(string1!)\(string2!)"
                }
            }
        let value: [String: Any] = [
            "prefix": "prefix",
            "value": "value",
            "f": filterValue]
        let template = try! Template(string:"{{f(prefix)(value)}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "prefixvalue")
    }
    
    func testImplicitIteratorCanReturnFilter() {
        let filter = Filter { (_: MustacheBox) in "filter" }
        let template = try! Template(string:"{{.(a)}}")
        let rendering = try! template.render(filter)
        XCTAssertEqual(rendering, "filter")
    }
    
    func testMissingFilterError() {
        let value: [String: Any] = [
            "name": "Name",
            "replace": Filter { (_: MustacheBox) in "replace" }
        ]
        
        var template = try! Template(string:"<{{missing(missing)}}>")
        do {
            _ = try template.render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        template = try! Template(string:"<{{missing(name)}}>")
        do {
            _ = try template.render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        template = try! Template(string:"<{{replace(missing(name))}}>")
        do {
            _ = try template.render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
        
        template = try! Template(string:"<{{missing(replace(name))}}>")
        do {
            _ = try template.render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testNotAFilterError() {
        let value = [
            "name": "Name",
            "filter": "filter"
            ]
        
        let template = try! Template(string:"<{{filter(name)}}>")
        do {
            _ = try template.render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsLineNumber() {
        let template = try! Template(string: "\n{{f(x)}}")
        do {
            _ = try template.render()
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
            XCTAssertTrue(error.description.range(of: "Missing filter") != nil)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsLineNumber() {
        let template = try! Template(string: "\n{{f(x)}}")
        do {
            _ = try template.render(["f": "foo"])
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
            XCTAssertTrue(error.description.range(of: "Not a filter") != nil)
            XCTAssertTrue(error.description.range(of: "line 2") != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
    
    func testFilterOfOptionalInt() {
        let square = Filter { (x: Int?) in
            if let x = x {
                return x * x
            } else {
                return "Nil"
            }
        }
        let template = try! Template(string: "{{square(x)}}")
        template.register(square, forKey: "square")
        
        var rendering: String
        
        rendering = try! template.render(["x": 10])
        XCTAssertEqual(rendering, "100")
        
        rendering = try! template.render(nil)
        XCTAssertEqual(rendering, "Nil")
        
        rendering = try! template.render(["x": NSNull()])
        XCTAssertEqual(rendering, "Nil")
        
        rendering = try! template.render(["x": "foo"])
        XCTAssertEqual(rendering, "Nil")
    }
    
    func testFilterOfOptionalString() {
        let twice = Filter { (x: String?) in
            if let x = x {
                return x + x
            } else {
                return "Nil"
            }
        }
        let template = try! Template(string: "{{twice(x)}}")
        template.register(twice, forKey: "twice")
        
        var rendering: String
        
        rendering = try! template.render(["x": "A"])
        XCTAssertEqual(rendering, "AA")
        
        rendering = try! template.render(["x": "A" as NSString])
        XCTAssertEqual(rendering, "AA")
        
        rendering = try! template.render(nil)
        XCTAssertEqual(rendering, "Nil")
        
        rendering = try! template.render(["x": NSNull()])
        XCTAssertEqual(rendering, "Nil")
        
        rendering = try! template.render(["x": 1])
        XCTAssertEqual(rendering, "Nil")
    }
    
    // TODO: import ValueTests.testCustomValueFilter(): testFilterOfOptionalXXX, testFilterOfXXX, etc. for all supported types
    
    func testFilterCanThrowMustacheError() {
        let filter = Filter { (box: MustacheBox) in
            throw MustacheError(kind: .renderError, message: "CustomMessage")
        }
        
        let template = try! Template(string: "\n\n{{f(x)}}")
        template.register(filter, forKey: "f")
        
        do {
            _ = try template.render()
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
            XCTAssertTrue(error.description.range(of: "CustomMessage") != nil)
            XCTAssertTrue(error.description.range(of: "line 3") != nil)
            XCTAssertTrue(error.description.range(of: "{{f(x)}}") != nil)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testFilterCanThrowCustomNSError() {
        let filter = Filter { (box: MustacheBox) in
            throw NSError(domain: "CustomErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "CustomMessage"])
        }
        
        let template = try! Template(string: "\n\n{{f(x)}}")
        template.register(filter, forKey: "f")
        
        do {
            _ = try template.render()
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
            if let nserror = error.underlyingError as NSError? {
                XCTAssertEqual(nserror.domain, "CustomErrorDomain")
            } else {
                XCTFail("Expected NSError")
            }
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testFilterCanThrowCustomError() {
        let filter = Filter { (box: MustacheBox) in
            throw CustomError.error
        }
        
        let template = try! Template(string: "\n\n{{f(x)}}")
        template.register(filter, forKey: "f")
        
        do {
            _ = try template.render()
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
            if let _ = error.underlyingError as? CustomError {
            } else {
                XCTFail("Expected NSError")
            }
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
}
