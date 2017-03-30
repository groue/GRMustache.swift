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

class HookFunctionTests: XCTestCase {
    
    enum CustomError : Error {
        case error
    }
    
    func testWillRenderFunctionIsNotTriggeredByText() {
        var success = true
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            success = false
            return box
        }
        let template = try! Template(string: "---")
        template.baseContext = template.baseContext.extendedContext(willRender)
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testDidRenderFunctionIsNotTriggeredByText() {
        var success = true
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            success = false
        }
        
        let template = try! Template(string: "---")
        template.baseContext = template.baseContext.extendedContext(didRender)
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testVariableHooks() {
        var preRenderingValue: MustacheBox?
        var preRenderingTagType: TagType?
        var postRenderingValue: MustacheBox?
        var postRenderingTagType: TagType?
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            preRenderingValue = box
            preRenderingTagType = tag.type
            return 1
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingValue = box
            postRenderingTagType = tag.type
        }
        
        let template = try! Template(string: "---{{foo}}---")
        template.baseContext = template.baseContext.extendedContext(MustacheBox(willRender: willRender, didRender: didRender))
        let rendering = try! template.render(["foo": "value"])
        
        XCTAssertEqual(rendering, "---1---")
        XCTAssertEqual(preRenderingTagType!, TagType.variable)
        XCTAssertEqual(postRenderingTagType!, TagType.variable)
        XCTAssertEqual((preRenderingValue?.value as! String), "value")
        XCTAssertEqual((postRenderingValue?.value as! Int), 1)
    }
    
    func testSectionHooks() {
        var preRenderingTagType: TagType?
        var postRenderingTagType: TagType?
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            preRenderingTagType = tag.type
            return box
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingTagType = tag.type
        }
        
        let template = try! Template(string: "<{{#false}}{{not_rendered}}{{/false}}>")
        template.baseContext = template.baseContext.extendedContext(MustacheBox(willRender: willRender, didRender: didRender))
        let rendering = try! template.render()
        
        XCTAssertEqual(rendering, "<>")
        XCTAssertEqual(preRenderingTagType!, TagType.section)
        XCTAssertEqual(postRenderingTagType!, TagType.section)
    }
    
    func testMultipleTagsObserver() {
        var preRenderingValues: [MustacheBox] = []
        var preRenderingTagTypes: [TagType] = []
        var postRenderingValues: [MustacheBox] = []
        var postRenderingTagTypes: [TagType] = []
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            preRenderingValues.append(box)
            preRenderingTagTypes.append(tag.type)
            if preRenderingValues.count == 1 {
                return true
            } else {
                return "observer"
            }
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingValues.append(box)
            postRenderingTagTypes.append(tag.type)
        }
        
        let template = try! Template(string: "<{{#foo}}{{bar}}{{/foo}}>")
        template.baseContext = template.baseContext.extendedContext(MustacheBox(willRender: willRender, didRender: didRender))
        let rendering = try! template.render()
        
        XCTAssertEqual(rendering, "<observer>")
        XCTAssertEqual(preRenderingValues.count, 2)
        XCTAssertEqual(postRenderingValues.count, 2)
        XCTAssertTrue(preRenderingValues[0].isEmpty)
        XCTAssertTrue(preRenderingValues[1].isEmpty)
        XCTAssertEqual((postRenderingValues[0].value as! String), "observer")
        XCTAssertEqual((postRenderingValues[1].value as! Bool), true)
        XCTAssertEqual(preRenderingTagTypes[0], TagType.section)
        XCTAssertEqual(preRenderingTagTypes[1], TagType.variable)
        XCTAssertEqual(postRenderingTagTypes[0], TagType.variable)
        XCTAssertEqual(postRenderingTagTypes[1], TagType.section)
    }
    
    func testObserverInterpretsRenderedValue() {
        var willRenderCount = 0;
        var renderedValue: MustacheBox? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            willRenderCount += 1
            renderedValue = box
            return box
        }
        let filter = { (string: String?) -> Any? in
            return string?.uppercased()
        }
        
        var template = try! Template(string: "{{subject}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        var rendering = try! template.render()
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = try! Template(string: "{{subject}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["subject": "foo"])
        XCTAssertEqual(rendering, "foo")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.value as! String), "foo")
        
        template = try! Template(string: "{{subject.foo}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render()
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = try! Template(string: "{{subject.foo}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["subject": "foo"])
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = try! Template(string: "{{subject.foo}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["subject": ["foo": "bar"]])
        XCTAssertEqual(rendering, "bar")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.value as! String), "bar")
        
        template = try! Template(string: "{{filter(subject)}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["filter": Filter(filter)])
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = try! Template(string: "{{filter(subject)}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["subject": "foo", "filter": Filter(filter)])
        XCTAssertEqual(rendering, "FOO")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.value as! String), "FOO")
        
        template = try! Template(string: "{{filter(subject).length}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        willRenderCount = 0
        renderedValue = nil
        rendering = try! template.render(["subject": "foo", "filter": Filter(filter)])
        XCTAssertEqual(rendering, "3")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.value as! Int), 3)
    }
    
    func testDidRenderFunctionObservesRenderedString() {
        var recordedRendering: String?
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            recordedRendering = string
        }
        let value = ["value": "<>"]
        
        var template = try! Template(string: "-{{value}}-")
        template.baseContext = template.baseContext.extendedContext(didRender)
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "-&lt;&gt;-")
        XCTAssertEqual(recordedRendering!, "&lt;&gt;")
        
        template = try! Template(string: "-{{{value}}}-")
        template.baseContext = template.baseContext.extendedContext(didRender)
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "-<>-")
        XCTAssertEqual(recordedRendering!, "<>")
    }
    
    func testDidRenderFunctionObservesRenderingNSError() {
        var failedRendering = false
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            failedRendering = (string == nil)
        }
        
        let template = try! Template(string: "-{{.}}-")
        template.baseContext = template.baseContext.extendedContext(didRender)
        failedRendering = false
        do {
            _ = try template.render({ (info: RenderingInfo) -> Rendering in
                throw NSError(domain: "TagObserverError", code: 1, userInfo: nil)
            })
            XCTAssert(false)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "TagObserverError")
            XCTAssertEqual(error.code, 1)
        }
        XCTAssertTrue(failedRendering)
    }
    
    func testDidRenderFunctionObservesRenderingCustomError() {
        var failedRendering = false
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            failedRendering = (string == nil)
        }
        
        let template = try! Template(string: "-\n\n{{.}}-")
        template.baseContext = template.baseContext.extendedContext(didRender)
        failedRendering = false
        do {
            _ = try template.render({ (info: RenderingInfo) -> Rendering in
                throw CustomError.error
            })
            XCTAssert(false)
        } catch CustomError.error {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
        XCTAssertTrue(failedRendering)
    }
    
    func testHookFunctionsOrdering() {
        var willRenderIndex = 0
        var didRenderIndex = 0
        
        var willRenderIndex1 = 0
        var didRenderIndex1 = 0
        let willRender1 = { (tag: Tag, box: MustacheBox) -> Any? in
            if box.value as? String == "observed" {
                willRenderIndex1 = willRenderIndex
                willRenderIndex += 1
            }
            return box
        }
        let didRender1 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex1 = didRenderIndex
                didRenderIndex += 1
            }
        }
        
        var willRenderIndex2 = 0
        var didRenderIndex2 = 0
        let willRender2 = { (tag: Tag, box: MustacheBox) -> Any? in
            if box.value as? String == "observed" {
                willRenderIndex2 = willRenderIndex
                willRenderIndex += 1
            }
            return box
        }
        let didRender2 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex2 = didRenderIndex
                didRenderIndex += 1
            }
        }
        
        var willRenderIndex3 = 0
        var didRenderIndex3 = 0
        let willRender3 = { (tag: Tag, box: MustacheBox) -> Any? in
            if box.value as? String == "observed" {
                willRenderIndex3 = willRenderIndex
                willRenderIndex += 1
            }
            return box
        }
        let didRender3 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex3 = didRenderIndex
                didRenderIndex += 1
            }
        }
        
        let template = try! Template(string: "{{#observer2}}{{#observer3}}{{observed}}{{/}}{{/}}")
        template.baseContext = template.baseContext.extendedContext(MustacheBox(willRender: willRender1, didRender: didRender1))
        let box: [String: Any] = [
            "observer2": MustacheBox(willRender: willRender2, didRender: didRender2),
            "observer3": MustacheBox(willRender: willRender3, didRender: didRender3),
            "observed": "observed"
            ]
        _ = try! template.render(box)
        
        XCTAssertEqual(willRenderIndex1, 2)
        XCTAssertEqual(willRenderIndex2, 1)
        XCTAssertEqual(willRenderIndex3, 0)
        
        XCTAssertEqual(didRenderIndex1, 0)
        XCTAssertEqual(didRenderIndex2, 1)
        XCTAssertEqual(didRenderIndex3, 2)
    }
    
    func testArrayOfWillRenderFunctionsInSectionTag() {
        var willRenderCalled1 = false
        let willRender1 = { (tag: Tag, box: MustacheBox) -> Any? in
            willRenderCalled1 = true
            return box
        }
        
        var willRenderCalled2 = false
        let willRender2 = { (tag: Tag, box: MustacheBox) -> Any? in
            willRenderCalled2 = true
            return box
        }
        
        let template = try! Template(string: "{{#items}}{{.}}{{/items}}")
        let value = ["items": [willRender1, willRender2]]
        _ = try! template.render(value)
        
        XCTAssertTrue(willRenderCalled1)
        XCTAssertTrue(willRenderCalled2)
    }
    
    func testWillRenderFunctionCanProcessRenderFunction() {
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            return { (info: RenderingInfo) -> Rendering in
                let rendering = try box.render(info)
                return Rendering(rendering.string.uppercased(), rendering.contentType)
            }
        }
        
        var render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&you")
        }
        var value: [String: Any] = ["object": render, "observer": willRender]
        var template = try! Template(string: "{{# observer }}{{ object }}{{/ }}")
        var rendering = try! template.render(value)
        XCTAssertEqual(rendering, "&amp;YOU")
        
        render = { (info: RenderingInfo) -> Rendering in
                return Rendering("&you", .html)
            }
        value = ["object": render, "observer": willRender]
        template = try! Template(string: "{{# observer }}{{ object }}{{/ }}")
        rendering = try! template.render(value)
        XCTAssertEqual(rendering, "&YOU")
    }
}
