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
    
    func testWillRenderFunctionIsNotTriggeredByText() {
        var success = true
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            success = false
            return box
        }
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testDidRenderFunctionIsNotTriggeredByText() {
        var success = true
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            success = false
        }
        
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.extendedContext(Box(didRender))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testVariableHooks() {
        var preRenderingValue: MustacheBox?
        var preRenderingTagType: TagType?
        var postRenderingValue: MustacheBox?
        var postRenderingTagType: TagType?
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            preRenderingValue = box
            preRenderingTagType = tag.type
            return Box(1)
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingValue = box
            postRenderingTagType = tag.type
        }
        
        let template = Template(string: "---{{foo}}---")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender: willRender, didRender: didRender))
        let rendering = template.render(Box(["foo": "value"]))!
        
        XCTAssertEqual(rendering, "---1---")
        XCTAssertEqual(preRenderingTagType!, TagType.Variable)
        XCTAssertEqual(postRenderingTagType!, TagType.Variable)
        XCTAssertEqual(preRenderingValue?.value as! String, "value")
        XCTAssertEqual(postRenderingValue?.value as! Int, 1)
    }
    
    func testSectionHooks() {
        var preRenderingTagType: TagType?
        var postRenderingTagType: TagType?
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            preRenderingTagType = tag.type
            return box
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingTagType = tag.type
        }
        
        let template = Template(string: "<{{#false}}{{not_rendered}}{{/false}}>")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender: willRender, didRender: didRender))
        let rendering = template.render()!
        
        XCTAssertEqual(rendering, "<>")
        XCTAssertEqual(preRenderingTagType!, TagType.Section)
        XCTAssertEqual(postRenderingTagType!, TagType.Section)
    }
    
    func testMultipleTagsObserver() {
        var preRenderingValues: [MustacheBox] = []
        var preRenderingTagTypes: [TagType] = []
        var postRenderingValues: [MustacheBox] = []
        var postRenderingTagTypes: [TagType] = []
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            preRenderingValues.append(box)
            preRenderingTagTypes.append(tag.type)
            if count(preRenderingValues) == 1 {
                return Box(true)
            } else {
                return Box("observer")
            }
        }
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            postRenderingValues.append(box)
            postRenderingTagTypes.append(tag.type)
        }
        
        let template = Template(string: "<{{#foo}}{{bar}}{{/foo}}>")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender: willRender, didRender: didRender))
        let rendering = template.render()!
        
        XCTAssertEqual(rendering, "<observer>")
        XCTAssertEqual(count(preRenderingValues), 2)
        XCTAssertEqual(count(postRenderingValues), 2)
        XCTAssertTrue(preRenderingValues[0].isEmpty)
        XCTAssertTrue(preRenderingValues[1].isEmpty)
        XCTAssertEqual(postRenderingValues[0].value as! String, "observer")
        XCTAssertEqual(postRenderingValues[1].value as! Bool, true)
        XCTAssertEqual(preRenderingTagTypes[0], TagType.Section)
        XCTAssertEqual(preRenderingTagTypes[1], TagType.Variable)
        XCTAssertEqual(postRenderingTagTypes[0], TagType.Variable)
        XCTAssertEqual(postRenderingTagTypes[1], TagType.Section)
    }
    
    func testObserverInterpretsRenderedValue() {
        var willRenderCount = 0;
        var renderedValue: MustacheBox? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            ++willRenderCount
            renderedValue = box
            return box
        }
        let filter = { (string: String?, error: NSErrorPointer) -> MustacheBox? in
            return Box(string?.uppercaseString)
        }
        
        var template = Template(string: "{{subject}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        var rendering = template.render()!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["subject": "foo"]))!
        XCTAssertEqual(rendering, "foo")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual(renderedValue!.value as! String, "foo")
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render()!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["subject": "foo"]))!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["subject": ["foo": "bar"]]))!
        XCTAssertEqual(rendering, "bar")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual(renderedValue!.value as! String, "bar")
        
        template = Template(string: "{{filter(subject)}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["filter": Box(Filter(filter))]))!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{filter(subject)}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["subject": Box("foo"), "filter": Box(Filter(filter))]))!
        XCTAssertEqual(rendering, "FOO")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual(renderedValue!.value as! String, "FOO")
        
        template = Template(string: "{{filter(subject).length}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Box(["subject": Box("foo"), "filter": Box(Filter(filter))]))!
        XCTAssertEqual(rendering, "3")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual(renderedValue!.value as! Int, 3)
    }
    
    func testDidRenderFunctionObservesRenderedString() {
        var recordedRendering: String?
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            recordedRendering = string
        }
        let box = Box(["value": "<>"])
        
        var template = Template(string: "-{{value}}-")!
        template.baseContext = template.baseContext.extendedContext(Box(didRender))
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "-&lt;&gt;-")
        XCTAssertEqual(recordedRendering!, "&lt;&gt;")
        
        template = Template(string: "-{{{value}}}-")!
        template.baseContext = template.baseContext.extendedContext(Box(didRender))
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "-<>-")
        XCTAssertEqual(recordedRendering!, "<>")
    }
    
    func testDidRenderFunctionObservesRenderingFailure() {
        var failedRendering = false
        let didRender = { (tag: Tag, box: MustacheBox, string: String?) in
            failedRendering = (string == nil)
        }
        
        let template = Template(string: "-{{.}}-")!
        template.baseContext = template.baseContext.extendedContext(Box(didRender))
        failedRendering = false
        var error: NSError?
        let rendering = template.render(Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: "TagObserverError", code: 1, userInfo: nil)
            return nil
        }), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, "TagObserverError")
        XCTAssertEqual(error!.code, 1)
        XCTAssertTrue(failedRendering)
    }
    
    func testHookFunctionsOrdering() {
        var willRenderIndex = 0
        var didRenderIndex = 0
        
        var willRenderIndex1 = 0
        var didRenderIndex1 = 0
        let willRender1 = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            if box.value as? String == "observed" {
                willRenderIndex1 = willRenderIndex
                willRenderIndex++
            }
            return box
        }
        let didRender1 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex1 = didRenderIndex
                didRenderIndex++
            }
        }
        
        var willRenderIndex2 = 0
        var didRenderIndex2 = 0
        let willRender2 = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            if box.value as? String == "observed" {
                willRenderIndex2 = willRenderIndex
                willRenderIndex++
            }
            return box
        }
        let didRender2 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex2 = didRenderIndex
                didRenderIndex++
            }
        }
        
        var willRenderIndex3 = 0
        var didRenderIndex3 = 0
        let willRender3 = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            if box.value as? String == "observed" {
                willRenderIndex3 = willRenderIndex
                willRenderIndex++
            }
            return box
        }
        let didRender3 = { (tag: Tag, box: MustacheBox, string: String?) -> Void in
            if box.value as? String == "observed" {
                didRenderIndex3 = didRenderIndex
                didRenderIndex++
            }
        }
        
        let template = Template(string: "{{#observer2}}{{#observer3}}{{observed}}{{/}}{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender: willRender1, didRender: didRender1))
        let box = Box([
            "observer2": Box(willRender: willRender2, didRender: didRender2),
            "observer3": Box(willRender: willRender3, didRender: didRender3),
            "observed": Box("observed")
            ])
        template.render(box)
        
        XCTAssertEqual(willRenderIndex1, 2)
        XCTAssertEqual(willRenderIndex2, 1)
        XCTAssertEqual(willRenderIndex3, 0)
        
        XCTAssertEqual(didRenderIndex1, 0)
        XCTAssertEqual(didRenderIndex2, 1)
        XCTAssertEqual(didRenderIndex3, 2)
    }
    
    func testArrayOfWillRenderFunctionsInSectionTag() {
        var willRenderCalled1 = false
        let willRender1 = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            willRenderCalled1 = true
            return box
        }
        
        var willRenderCalled2 = false
        let willRender2 = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            willRenderCalled2 = true
            return box
        }
        
        let template = Template(string: "{{#items}}{{.}}{{/items}}")!
        let box = Box(["items": Box([Box(willRender1), Box(willRender2)])])
        template.render(box)
        
        XCTAssertTrue(willRenderCalled1)
        XCTAssertTrue(willRenderCalled2)
    }
    
    func testWillRenderFunctionCanProcessRenderFunction() {
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            return Box({ (info, error) -> Rendering? in
                let rendering = box.render(info: info, error: error)!
                return Rendering(rendering.string.uppercaseString, rendering.contentType)
            })
        }
        
        var render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&you")
        }
        var box = Box(["object": Box(render), "observer": Box(willRender)])
        var template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "&amp;YOU")
        
        render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                return Rendering("&you", .HTML)
            }
        box = Box(["object": Box(render), "observer": Box(willRender)])
        template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "&YOU")
    }
}
