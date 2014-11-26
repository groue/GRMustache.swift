//
//  TagObserverTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class TagObserverTests: XCTestCase {
    
    struct TestedTagObserver: MustacheTagObserver {
        let willRenderBlock: ((tag: Tag, value: Value) -> Value)?
        let didRenderBlock: ((tag: Tag, rendering: String?, value: Value) -> Void)?
        
        func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
            if let block = willRenderBlock {
                return block(tag: tag, value: value)
            } else {
                return value
            }
        }
        
        func mustacheTag(tag: Tag, didRender rendering: String?, forValue value: Value) {
            if let block = didRenderBlock {
                block(tag: tag, rendering: rendering, value: value)
            }
        }
    }
    
    func testMustacheTagWillRenderIsNotTriggeredByText() {
        var success = true
        let tagObserver = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            success = false
            return value
            }, didRenderBlock: nil)
        
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render()!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testMustacheTagDidRenderIsNotTriggeredByText() {
        var success = true
        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: { (tag: Tag, rendering: String?, value: Value) in
            success = false
        })
        
        let template = Template(string: "---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render()!
        XCTAssertEqual(rendering, "---")
        XCTAssertTrue(success)
    }
    
    func testVariableTagObserver() {
        var preRenderingValue: Value?
        var preRenderingTagType: TagType?
        var postRenderingValue: Value?
        var postRenderingTagType: TagType?
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            preRenderingValue = value
            preRenderingTagType = tag.type
            return Value(1)
        }
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) -> Void in
            postRenderingValue = value
            postRenderingTagType = tag.type
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "---{{foo}}---")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render(Value(["foo": "value"]))!
        
        XCTAssertEqual(rendering, "---1---")
        XCTAssertEqual(preRenderingTagType!, TagType.Variable)
        XCTAssertEqual(postRenderingTagType!, TagType.Variable)
        XCTAssertEqual((preRenderingValue?.object() as String?)!, "value")
        XCTAssertEqual((postRenderingValue?.object() as Int?)!, 1)
    }
    
    func testSectionTagObserver() {
        var preRenderingTagType: TagType?
        var postRenderingTagType: TagType?
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            preRenderingTagType = tag.type
            return value
        }
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) -> Void in
            postRenderingTagType = tag.type
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "<{{#false}}{{not_rendered}}{{/false}}>")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render()!
        
        XCTAssertEqual(rendering, "<>")
        XCTAssertEqual(preRenderingTagType!, TagType.Section)
        XCTAssertEqual(postRenderingTagType!, TagType.Section)
    }
    
    func testMultipleTagsObserver() {
        var preRenderingValues: [Value] = []
        var preRenderingTagTypes: [TagType] = []
        var postRenderingValues: [Value] = []
        var postRenderingTagTypes: [TagType] = []
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            preRenderingValues.append(value)
            preRenderingTagTypes.append(tag.type)
            if countElements(preRenderingValues) == 1 {
                return Value(true)
            } else {
                return Value("observer")
            }
        }
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) -> Void in
            postRenderingValues.append(value)
            postRenderingTagTypes.append(tag.type)
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "<{{#foo}}{{bar}}{{/foo}}>")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        let rendering = template.render()!
        
        XCTAssertEqual(rendering, "<observer>")
        XCTAssertEqual(countElements(preRenderingValues), 2)
        XCTAssertEqual(countElements(postRenderingValues), 2)
        XCTAssertTrue(preRenderingValues[0].isEmpty)
        XCTAssertTrue(preRenderingValues[1].isEmpty)
        XCTAssertEqual((postRenderingValues[0].object() as String?)!, "observer")
        XCTAssertEqual((postRenderingValues[1].object() as Bool?)!, true)
        XCTAssertEqual(preRenderingTagTypes[0], TagType.Section)
        XCTAssertEqual(preRenderingTagTypes[1], TagType.Variable)
        XCTAssertEqual(postRenderingTagTypes[0], TagType.Variable)
        XCTAssertEqual(postRenderingTagTypes[1], TagType.Section)
    }
    
    func testObserverInterpretsRenderedValue() {
        var willRenderCount = 0;
        var renderedValue: Value? = nil
        let willRenderBlock = { (tag: Tag, value: Value) -> Value in
            ++willRenderCount
            renderedValue = value
            return value
        }
        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: nil)
        
        let filter = { (string: String?) -> Value in
            return Value(string?.uppercaseString)
        }
        
        var template = Template(string: "{{subject}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        var rendering = template.render()!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["subject": "foo"]))!
        XCTAssertEqual(rendering, "foo")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.object() as String?)!, "foo")
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render()!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["subject": "foo"]))!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{subject.foo}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["subject": ["foo": "bar"]]))!
        XCTAssertEqual(rendering, "bar")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.object() as String?)!, "bar")
        
        template = Template(string: "{{filter(subject)}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["filter": Value(filter)]))!
        XCTAssertEqual(rendering, "")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertTrue(renderedValue!.isEmpty)
        
        template = Template(string: "{{filter(subject)}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["subject": Value("foo"), "filter": Value(filter)]))!
        XCTAssertEqual(rendering, "FOO")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.object() as String?)!, "FOO")
        
        template = Template(string: "{{filter(subject).length}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        willRenderCount = 0
        renderedValue = nil
        rendering = template.render(Value(["subject": Value("foo"), "filter": Value(filter)]))!
        XCTAssertEqual(rendering, "3")
        XCTAssertEqual(willRenderCount, 1)
        XCTAssertEqual((renderedValue!.object() as Int?)!, 3)
    }
    
    func testTagObserverObservesRenderedString() {
        var recordedRendering: String?
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) in
            recordedRendering = rendering
        }
        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: didRenderBlock)
        let value = Value(["value": "<>"])
        
        var template = Template(string: "-{{value}}-")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        var rendering = template.render(value)!
        XCTAssertEqual(rendering, "-&lt;&gt;-")
        XCTAssertEqual(recordedRendering!, "&lt;&gt;")
        
        template = Template(string: "-{{{value}}}-")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "-<>-")
        XCTAssertEqual(recordedRendering!, "<>")
    }
    
    func testTagObserverObservesRenderingFailure() {
        var failedRendering = false
        let didRenderBlock = { (tag: Tag, rendering: String?, value: Value) in
            failedRendering = (rendering == nil)
        }
        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: didRenderBlock)
        
        let template = Template(string: "-{{.}}-")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver)
        failedRendering = false
        var error: NSError?
        let rendering = template.render(Value({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: "TagObserverError", code: 1, userInfo: nil)
            return nil
        }), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, "TagObserverError")
        XCTAssertEqual(error!.code, 1)
        XCTAssertTrue(failedRendering)
    }
    
    func testTagObserverOrdering() {
        var willRenderIndex = 0
        var didRenderIndex = 0
        
        var willRenderIndex1 = 0
        var didRenderIndex1 = 0
        let tagObserver1 = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            if value.toString() == "observed" {
                willRenderIndex1 = willRenderIndex
                willRenderIndex++
            }
            return value
            }, didRenderBlock: { (tag: Tag, rendering: String?, value: Value) in
                if value.toString() == "observed" {
                    didRenderIndex1 = didRenderIndex
                    didRenderIndex++
                }
        })
        
        var willRenderIndex2 = 0
        var didRenderIndex2 = 0
        let tagObserver2 = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            if value.toString() == "observed" {
                willRenderIndex2 = willRenderIndex
                willRenderIndex++
            }
            return value
            }, didRenderBlock: { (tag: Tag, rendering: String?, value: Value) in
                if value.toString() == "observed" {
                    didRenderIndex2 = didRenderIndex
                    didRenderIndex++
                }
        })
        
        var willRenderIndex3 = 0
        var didRenderIndex3 = 0
        let tagObserver3 = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            if value.toString() == "observed" {
                willRenderIndex3 = willRenderIndex
                willRenderIndex++
            }
            return value
            }, didRenderBlock: { (tag: Tag, rendering: String?, value: Value) in
                if value.toString() == "observed" {
                    didRenderIndex3 = didRenderIndex
                    didRenderIndex++
                }
        })
        
        let template = Template(string: "{{#observer2}}{{#observer3}}{{observed}}{{/}}{{/}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(tagObserver1)
        let value = Value([
            "observer2": Value(tagObserver2),
            "observer3": Value(tagObserver3),
            "observed": Value("observed")
            ])
        template.render(value)
        
        XCTAssertEqual(willRenderIndex1, 2)
        XCTAssertEqual(willRenderIndex2, 1)
        XCTAssertEqual(willRenderIndex3, 0)
        
        XCTAssertEqual(didRenderIndex1, 0)
        XCTAssertEqual(didRenderIndex2, 1)
        XCTAssertEqual(didRenderIndex3, 2)
    }
    
    func testArrayOfTagDelegatesInSectionTag() {
        var willRender1 = false
        let tagObserver1 = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            willRender1 = true
            return value
            }, didRenderBlock: nil)
        
        var willRender2 = false
        let tagObserver2 = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            willRender2 = true
            return value
            }, didRenderBlock: nil)
        
        let template = Template(string: "{{#items}}{{.}}{{/items}}")!
        let value = Value(["items": Value([Value(tagObserver1), Value(tagObserver2)])])
        template.render(value)
        
        XCTAssertTrue(willRender1)
        XCTAssertTrue(willRender2)
    }
    
    func testTagDelegateCanProcessMustacheRenderable() {
        let tagObserver = TestedTagObserver(willRenderBlock: { (tag, value) -> Value in
            return Value({ (info, error) -> Rendering? in
                let rendering = value.render(info, error: error)!
                return Rendering(rendering.string.uppercaseString, rendering.contentType)
            })
            }, didRenderBlock: nil)
        
        var object = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                return Rendering("&you")
            }
        var value = Value(["object": Value(object), "observer": Value(tagObserver)])
        var template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
        var rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;YOU")
        
        object = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                return Rendering("&you", .HTML)
            }
        value = Value(["object": Value(object), "observer": Value(tagObserver)])
        template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "&YOU")
    }
}
