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

class VariadicFilterTests: XCTestCase {

    func testVariadicFilterCanAccessArguments() {
        let filter = VariadicFilter({ (boxes: [MustacheBox]) -> Any? in
            return boxes.map { ($0.value as? String) ?? "" }.joined(separator: ",")
        })
        let value: [String: Any] = [
            "a": "a",
            "b": "b",
            "c": "c",
            "join": filter]
        let template = try! Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "a a,b a,b,c")
    }

    func testVariadicFilterCanReturnFilter() {
        let filter = VariadicFilter({ (boxes: [MustacheBox]) -> Any? in
            let joined = boxes.map { ($0.value as? String) ?? "" }.joined(separator: ",")
            return Filter { (box: MustacheBox) -> Any? in
                return joined + "+" + ((box.value as? String) ?? "")
            }
        })
        let value: [String: Any] = [
            "a": "a",
            "b": "b",
            "c": "c",
            "f": filter]
        let template = try! Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
    }
    
    func testVariadicFilterCanBeRootOfScopedExpression() {
        let filter = VariadicFilter({ (boxes: [MustacheBox]) -> Any? in
            return ["foo": "bar"]
        })
        let value = ["f": filter]
        let template = try! Template(string:"{{f(a,b).foo}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForObjectSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox]) -> Any? in
            return ["foo": "bar"]
        })
        let value = ["f": filter]
        let template = try! Template(string:"{{#f(a,b)}}{{foo}}{{/}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForEnumerableSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox]) -> Any? in
            return boxes
        })
        let value: [String: Any] = [
            "a": "a",
            "b": "b",
            "c": "c",
            "f": filter]
        let template = try! Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "ab abc")
    }
    
    func testVariadicFilterCanBeUsedForBooleanSections() {
        let filter = VariadicFilter { (boxes) -> Any? in
            return boxes.first!
        }
        let value: [String: Any] = [
            "yes": true,
            "no": false,
            "f": filter]
        let template = try! Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "YES NO")
    }
    
    func testImplicitIteratorCanBeVariadicFilterArgument() {
        let value: [String: Any] = [
            "f": VariadicFilter { (boxes) -> Any? in
                var result = ""
                for box in boxes {
                    if let dictionary = box.dictionaryValue {
                        result += String(dictionary.count)
                    }
                }
                return result
            },
            "foo": ["a": "a", "b": "b", "c": "c"]
            ]
        let template = try! Template(string:"{{f(foo,.)}} {{f(.,foo)}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "32 23")
    }
}
