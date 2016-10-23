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

class ContextRegisteredKeyTests: XCTestCase {
    
    func testRegisteredKeyCanBeAccessed() {
        let template = try! Template(string: "{{safe}}")
        template.register("important", forKey: "safe")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "important")
    }
    
    func testMultipleRegisteredKeysCanBeAccessed() {
        let template = try! Template(string: "{{safe1}}, {{safe2}}")
        template.register("important1", forKey: "safe1")
        template.register("important2", forKey: "safe2")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "important1, important2")
    }
    
    func testRegisteredKeysCanNotBeShadowed() {
        let template = try! Template(string: "{{safe}}, {{fragile}}")
        template.register("important", forKey: "safe")
        let rendering = try! template.render(["safe": "error", "fragile": "not important"])
        XCTAssertEqual(rendering, "important, not important")
    }
    
    func testDeepRegisteredKeyCanBeAccessedViaFullKeyPath() {
        let template = try! Template(string: "{{safe.name}}")
        template.register(["name": "important"], forKey: "safe")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "important")
    }
    
    func testDeepRegisteredKeyCanBeAccessedViaScopedExpression() {
        let template = try! Template(string: "{{#safe}}{{.name}}{{/safe}}")
        template.register(["name": "important"], forKey: "safe")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "important")
    }
    
    func testDeepRegisteredKeyCanBeShadowed() {
        // This is more a caveat than a feature, isn't it?
        let template = try! Template(string: "{{#safe}}{{#evil}}{{name}}{{/evil}}{{/safe}}")
        template.register(["name": "important"], forKey: "safe")
        let rendering = try! template.render(["evil": ["name": "hacked"]])
        XCTAssertEqual(rendering, "hacked")
    }
}
