//
//  MustacheRenderableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class MustacheRenderableTests: XCTestCase {

    func testRenderablePerformsVariableRendering() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectExplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectImplicitTextRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "MustacheClusterTests"
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        })
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "MustacheClusterTests"
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        })
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{.}}>", error: nil)!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{#.}}{{/.}}>", error: nil)!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch renderingInfo.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch renderingInfo.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{subject}}{{/.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{^.}}{{#.}}{{subject}}{{/.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}", error: nil)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}", error: nil)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = MustacheTemplate(string:"{{subject}}", error: nil)!
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}", error: nil)
        XCTAssertEqual(rendering!, "-")
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = MustacheTemplate(string:"{{subject}}", error: nil)!
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}{{/renderable}}", error: nil)
        XCTAssertEqual(rendering!, "-")
    }

    func testRenderableObjectDoesNotAutomaticallyEntersVariableContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue("value")
            }
            func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return MustacheTemplate(string:"key:{{key}}", error: nil)!.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = MustacheValue(["renderable": MustacheValue(TestedRenderable())])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}", error: nil)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectDoesNotAutomaticallyEntersSectionContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue("value")
            }
            func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
                return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = MustacheValue(["renderable": MustacheValue(TestedRenderable())])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}key:{{key}}{{/renderable}}", error: nil)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectCanExtendValueContextStackInVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(["subject2": MustacheValue("+++")]))
            let template = MustacheTemplate(string: "{{subject}}{{subject2}}", error: nil)!
            return template.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}", error: nil)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendValueContextStackInSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(["subject2": MustacheValue("+++")]))
            // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}{{subject}}{{subject2}}{{/renderable}}", error: nil)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendTagObserverStackInVariableTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                let template = MustacheTemplate(string: "{{subject}}{{subject}}", error: nil)!
                return template.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        let renderable = TestedRenderable()
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{subject}}{{renderable}}{{subject}}{{subject}}{{subject}}{{subject}}", error: nil)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectCanExtendTagObserverStackInSectionTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                // TODO: "renderingInfo.tag.mustacheRendering(renderingInfo" is not a nice API.
                return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        let renderable = TestedRenderable()
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{subject}}{{#renderable}}{{subject}}{{subject}}{{/renderable}}{{subject}}{{subject}}{{subject}}{{subject}}", error: nil)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectTriggersTagObserverCallbacks() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        
        let template = MustacheTemplate(string: "{{#renderable}}{{subject}}{{/renderable}}", error: nil)!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromVariableTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = MustacheTemplate(string: "{{subject}}", error: nil)!
            return template.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        
        let template = MustacheTemplate(string: "{{renderable}}", error: nil)!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromSectionTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = MustacheTemplate(string: "{{subject}}", error: nil)!
            return template.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        
        let template = MustacheTemplate(string: "{{#renderable}}{{/renderable}}", error: nil)!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderableObjectsInSectionTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{#items}}{{/items}}", error: nil)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderableObjectsInEscapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: nil)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInEscapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: nil)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}", error: nil)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: nil)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}", error: nil)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: nil)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}", error: nil)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInVariableTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        var error: NSError?
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInSectionTag() {
        let renderable1 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        })
        let renderable2 = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        })
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        var error: NSError?
        let rendering = MustacheTemplate.render(value, fromString: "{{#items}}{{/items}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testMustacheTemplateAsRenderableObject() {
        let repository = MustacheTemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.templateNamed("partial", error: nil)!
        let value = MustacheValue(["partial": MustacheValue(template), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{partial}}", error: nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testMustacheTemplateAsRenderableObjectInNotHTMLEscaped() {
        let repository = MustacheTemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.templateNamed("partial", error: nil)!
        let value = MustacheValue(["partial": MustacheValue(template), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{partial}}", error: nil)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{renderable}}",
            "partial": "{{subject}}",
        ]
        let repository = MustacheTemplateRepository(templates: templates)
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let altTemplate = MustacheTemplate(string: "{{>partial}}", error:nil)!
            return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let template = repository.templateNamed("template", error: nil)!
        let rendering = template.render(value, error: nil)
        XCTAssertEqual(rendering!, "-")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfMustacheTemplateAsRenderableObject() {
        let repository1 = MustacheTemplateRepository(templates: [
            "template1": "{{ renderable }}|{{ template2 }}",
            "partial": "partial1"])
        let repository2 = MustacheTemplateRepository(templates: [
            "template2": "{{ renderable }}",
            "partial": "partial2"])
        let value = MustacheValue([
            "template2": MustacheValue(repository2.templateNamed("template2", error: nil)!),
            "renderable": MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{>partial}}", error:nil)!
                return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }))])
        let template = repository1.templateNamed("template1", error:nil)!
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderableObjectInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let value = MustacheValue([
            "object": MustacheValue("&"),
            "renderable": MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ object }}", error:nil)!
                return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }))])
        
        let template = MustacheTemplate(string: "{{%CONTENT_TYPE:HTML}}{{renderable}}", error: nil)!
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let value = MustacheValue([
            "object": MustacheValue("&"),
            "renderable": MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ object }}", error:nil)!
                return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }))])
        
        let template = MustacheTemplate(string: "{{%CONTENT_TYPE:TEXT}}{{renderable}}", error: nil)!
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectInheritContentTypeFromPartial() {
        let repository = MustacheTemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ renderable }}"])
        let value = MustacheValue([
            "value": MustacheValue("&"),
            "renderable": MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ value }}", error:nil)!
                return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }))])
        let template = repository.templateNamed("templateHTML", error: nil)!
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "&amp;|&amp;")
    }
    
    func testRenderableObjectInheritContentTypeFromMustacheTemplateAsRenderableObject() {
        let repository1 = MustacheTemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{ templateText }}"])
        let repository2 = MustacheTemplateRepository(templates: [
            "templateText": "{{ renderable }}"])
        repository2.configuration.contentType = .Text
        
        let value = MustacheValue([
            "value": MustacheValue("&"),
            "templateText": MustacheValue(repository2.templateNamed("templateText", error: nil)!),
            "renderable": MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{{ value }}}", error:nil)!
                return altTemplate.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }))])
        let template = repository1.templateNamed("templateHTML", error: nil)!
        let rendering = template.render(value, error: nil)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
}
