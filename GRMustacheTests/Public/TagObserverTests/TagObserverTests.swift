//
//  TagObserverTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

//class TagObserverTests: XCTestCase {
//    
//    struct TestedTagObserver: MustacheTagObserver {
//        let willRenderBlock: ((tag: Tag, box: Box) -> Box)?
//        let didRenderBlock: ((tag: Tag, box: Box, string: String?) -> Void)?
//        
//        func mustacheTag(tag: Tag, willRender box: Box) -> Box {
//            if let block = willRenderBlock {
//                return block(tag: tag, box: box)
//            } else {
//                return box
//            }
//        }
//        
//        func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
//            if let block = didRenderBlock {
//                block(tag: tag, box: box, string: string)
//            }
//        }
//    }
//    
//    func testMustacheTagWillRenderIsNotTriggeredByText() {
//        var success = true
//        let tagObserver = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            success = false
//            return box
//            }, didRenderBlock: nil)
//        
//        let template = Template(string: "---")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        let rendering = template.render()!
//        XCTAssertEqual(rendering, "---")
//        XCTAssertTrue(success)
//    }
//    
//    func testMustacheTagDidRenderIsNotTriggeredByText() {
//        var success = true
//        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: { (tag: Tag, box: Box, string: String?) in
//            success = false
//        })
//        
//        let template = Template(string: "---")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        let rendering = template.render()!
//        XCTAssertEqual(rendering, "---")
//        XCTAssertTrue(success)
//    }
//    
//    func testVariableTagObserver() {
//        var preRenderingValue: Box?
//        var preRenderingTagType: TagType?
//        var postRenderingValue: Box?
//        var postRenderingTagType: TagType?
//        let willRenderBlock = { (tag: Tag, box: Box) -> Box in
//            preRenderingValue = box
//            preRenderingTagType = tag.type
//            return Box(1)
//        }
//        let didRenderBlock = { (tag: Tag, box: Box, string: String?) -> Void in
//            postRenderingValue = box
//            postRenderingTagType = tag.type
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
//        
//        let template = Template(string: "---{{foo}}---")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        let rendering = template.render(Box(["foo": "value"]))!
//        
//        XCTAssertEqual(rendering, "---1---")
//        XCTAssertEqual(preRenderingTagType!, TagType.Variable)
//        XCTAssertEqual(postRenderingTagType!, TagType.Variable)
//        XCTAssertEqual((preRenderingValue?.value() as String?)!, "value")
//        XCTAssertEqual((postRenderingValue?.value() as Int?)!, 1)
//    }
//    
//    func testSectionTagObserver() {
//        var preRenderingTagType: TagType?
//        var postRenderingTagType: TagType?
//        let willRenderBlock = { (tag: Tag, box: Box) -> Box in
//            preRenderingTagType = tag.type
//            return box
//        }
//        let didRenderBlock = { (tag: Tag, box: Box, string: String?) -> Void in
//            postRenderingTagType = tag.type
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
//        
//        let template = Template(string: "<{{#false}}{{not_rendered}}{{/false}}>")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        let rendering = template.render()!
//        
//        XCTAssertEqual(rendering, "<>")
//        XCTAssertEqual(preRenderingTagType!, TagType.Section)
//        XCTAssertEqual(postRenderingTagType!, TagType.Section)
//    }
//    
//    func testMultipleTagsObserver() {
//        var preRenderingValues: [Box] = []
//        var preRenderingTagTypes: [TagType] = []
//        var postRenderingValues: [Box] = []
//        var postRenderingTagTypes: [TagType] = []
//        let willRenderBlock = { (tag: Tag, box: Box) -> Box in
//            preRenderingValues.append(box)
//            preRenderingTagTypes.append(tag.type)
//            if countElements(preRenderingValues) == 1 {
//                return Box(true)
//            } else {
//                return Box("observer")
//            }
//        }
//        let didRenderBlock = { (tag: Tag, box: Box, string: String?) -> Void in
//            postRenderingValues.append(box)
//            postRenderingTagTypes.append(tag.type)
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: didRenderBlock)
//        
//        let template = Template(string: "<{{#foo}}{{bar}}{{/foo}}>")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        let rendering = template.render()!
//        
//        XCTAssertEqual(rendering, "<observer>")
//        XCTAssertEqual(countElements(preRenderingValues), 2)
//        XCTAssertEqual(countElements(postRenderingValues), 2)
//        XCTAssertTrue(preRenderingValues[0].isEmpty)
//        XCTAssertTrue(preRenderingValues[1].isEmpty)
//        XCTAssertEqual((postRenderingValues[0].value() as String?)!, "observer")
//        XCTAssertEqual((postRenderingValues[1].value() as Bool?)!, true)
//        XCTAssertEqual(preRenderingTagTypes[0], TagType.Section)
//        XCTAssertEqual(preRenderingTagTypes[1], TagType.Variable)
//        XCTAssertEqual(postRenderingTagTypes[0], TagType.Variable)
//        XCTAssertEqual(postRenderingTagTypes[1], TagType.Section)
//    }
//    
//    func testObserverInterpretsRenderedValue() {
//        var willRenderCount = 0;
//        var renderedValue: Box? = nil
//        let willRenderBlock = { (tag: Tag, box: Box) -> Box in
//            ++willRenderCount
//            renderedValue = box
//            return box
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: willRenderBlock, didRenderBlock: nil)
//        
//        let filter = { (string: String?, error: NSErrorPointer) -> Box? in
//            return Box(string?.uppercaseString)
//        }
//        
//        var template = Template(string: "{{subject}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        var rendering = template.render()!
//        XCTAssertEqual(rendering, "")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertTrue(renderedValue!.isEmpty)
//        
//        template = Template(string: "{{subject}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["subject": "foo"]))!
//        XCTAssertEqual(rendering, "foo")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertEqual((renderedValue!.value() as String?)!, "foo")
//        
//        template = Template(string: "{{subject.foo}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render()!
//        XCTAssertEqual(rendering, "")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertTrue(renderedValue!.isEmpty)
//        
//        template = Template(string: "{{subject.foo}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["subject": "foo"]))!
//        XCTAssertEqual(rendering, "")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertTrue(renderedValue!.isEmpty)
//        
//        template = Template(string: "{{subject.foo}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["subject": ["foo": "bar"]]))!
//        XCTAssertEqual(rendering, "bar")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertEqual((renderedValue!.value() as String?)!, "bar")
//        
//        template = Template(string: "{{filter(subject)}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["filter": BoxedFilter(filter)]))!
//        XCTAssertEqual(rendering, "")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertTrue(renderedValue!.isEmpty)
//        
//        template = Template(string: "{{filter(subject)}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["subject": Box("foo"), "filter": BoxedFilter(filter)]))!
//        XCTAssertEqual(rendering, "FOO")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertEqual((renderedValue!.value() as String?)!, "FOO")
//        
//        template = Template(string: "{{filter(subject).length}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        willRenderCount = 0
//        renderedValue = nil
//        rendering = template.render(Box(["subject": Box("foo"), "filter": BoxedFilter(filter)]))!
//        XCTAssertEqual(rendering, "3")
//        XCTAssertEqual(willRenderCount, 1)
//        XCTAssertEqual((renderedValue!.value() as Int?)!, 3)
//    }
//    
//    func testTagObserverObservesRenderedString() {
//        var recordedRendering: String?
//        let didRenderBlock = { (tag: Tag, box: Box, string: String?) in
//            recordedRendering = string
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: didRenderBlock)
//        let box = Box(["value": "<>"])
//        
//        var template = Template(string: "-{{value}}-")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        var rendering = template.render(box)!
//        XCTAssertEqual(rendering, "-&lt;&gt;-")
//        XCTAssertEqual(recordedRendering!, "&lt;&gt;")
//        
//        template = Template(string: "-{{{value}}}-")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        rendering = template.render(box)!
//        XCTAssertEqual(rendering, "-<>-")
//        XCTAssertEqual(recordedRendering!, "<>")
//    }
//    
//    func testTagObserverObservesRenderingFailure() {
//        var failedRendering = false
//        let didRenderBlock = { (tag: Tag, box: Box, string: String?) in
//            failedRendering = (string == nil)
//        }
//        let tagObserver = TestedTagObserver(willRenderBlock: nil, didRenderBlock: didRenderBlock)
//        
//        let template = Template(string: "-{{.}}-")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver)
//        failedRendering = false
//        var error: NSError?
//        let rendering = template.render(Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            error.memory = NSError(domain: "TagObserverError", code: 1, userInfo: nil)
//            return nil
//        }), error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, "TagObserverError")
//        XCTAssertEqual(error!.code, 1)
//        XCTAssertTrue(failedRendering)
//    }
//    
//    func testTagObserverOrdering() {
//        var willRenderIndex = 0
//        var didRenderIndex = 0
//        
//        var willRenderIndex1 = 0
//        var didRenderIndex1 = 0
//        let tagObserver1 = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            if box.toString() == "observed" {
//                willRenderIndex1 = willRenderIndex
//                willRenderIndex++
//            }
//            return box
//            }, didRenderBlock: { (tag: Tag, box: Box, string: String?) in
//                if box.toString() == "observed" {
//                    didRenderIndex1 = didRenderIndex
//                    didRenderIndex++
//                }
//        })
//        
//        var willRenderIndex2 = 0
//        var didRenderIndex2 = 0
//        let tagObserver2 = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            if box.toString() == "observed" {
//                willRenderIndex2 = willRenderIndex
//                willRenderIndex++
//            }
//            return box
//            }, didRenderBlock: { (tag: Tag, box: Box, string: String?) in
//                if box.toString() == "observed" {
//                    didRenderIndex2 = didRenderIndex
//                    didRenderIndex++
//                }
//        })
//        
//        var willRenderIndex3 = 0
//        var didRenderIndex3 = 0
//        let tagObserver3 = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            if box.toString() == "observed" {
//                willRenderIndex3 = willRenderIndex
//                willRenderIndex++
//            }
//            return box
//            }, didRenderBlock: { (tag: Tag, box: Box, string: String?) in
//                if box.toString() == "observed" {
//                    didRenderIndex3 = didRenderIndex
//                    didRenderIndex++
//                }
//        })
//        
//        let template = Template(string: "{{#observer2}}{{#observer3}}{{observed}}{{/}}{{/}}")!
//        template.baseContext = template.baseContext.extendedContext(tagObserver: tagObserver1)
//        let box = Box([
//            "observer2": Box(tagObserver2),
//            "observer3": Box(tagObserver3),
//            "observed": Box("observed")
//            ])
//        template.render(box)
//        
//        XCTAssertEqual(willRenderIndex1, 2)
//        XCTAssertEqual(willRenderIndex2, 1)
//        XCTAssertEqual(willRenderIndex3, 0)
//        
//        XCTAssertEqual(didRenderIndex1, 0)
//        XCTAssertEqual(didRenderIndex2, 1)
//        XCTAssertEqual(didRenderIndex3, 2)
//    }
//    
//    func testArrayOfTagDelegatesInSectionTag() {
//        var willRender1 = false
//        let tagObserver1 = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            willRender1 = true
//            return box
//            }, didRenderBlock: nil)
//        
//        var willRender2 = false
//        let tagObserver2 = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            willRender2 = true
//            return box
//            }, didRenderBlock: nil)
//        
//        let template = Template(string: "{{#items}}{{.}}{{/items}}")!
//        let box = Box(["items": Box([Box(tagObserver1), Box(tagObserver2)])])
//        template.render(box)
//        
//        XCTAssertTrue(willRender1)
//        XCTAssertTrue(willRender2)
//    }
//    
//    func testTagDelegateCanProcessRenderFunction() {
//        let tagObserver = TestedTagObserver(willRenderBlock: { (tag, box) -> Box in
//            return Box({ (info, error) -> Rendering? in
//                let rendering = box.render(info, error: error)!
//                return Rendering(rendering.string.uppercaseString, rendering.contentType)
//            })
//            }, didRenderBlock: nil)
//        
//        var object = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                return Rendering("&you")
//            }
//        var box = Box(["object": Box(object), "observer": Box(tagObserver)])
//        var template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
//        var rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&amp;YOU")
//        
//        object = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                return Rendering("&you", .HTML)
//            }
//        box = Box(["object": Box(object), "observer": Box(tagObserver)])
//        template = Template(string: "{{# observer }}{{ object }}{{/ }}")!
//        rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&YOU")
//    }
//}
