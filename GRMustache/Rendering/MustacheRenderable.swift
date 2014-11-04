//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct RenderingInfo {
    let context: Context
    let tag: Tag
    let enumerationItem: Bool
    
    func renderingInfoByExtendingContextWithValue(value: MustacheValue) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingValue(value), tag: tag, enumerationItem: enumerationItem)
    }
    
    func renderingInfoByExtendingContextWithTagObserver(tagObserver: MustacheTagObserver) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingTagObserver(tagObserver), tag: tag, enumerationItem: enumerationItem)
    }
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(context: context, tag: tag, enumerationItem: true)
    }
}

protocol MustacheTagObserver {
    func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue
    
    // If rendering is nil then an error has occurred.
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue)
}

protocol MustacheRenderable {
    
    /**
    Controls whether the renderable object should trigger or avoid the rendering
    of Mustache sections.
    
    - true: `{{#renderable}}...{{/}}` are rendered, `{{^renderable}}...{{/}}`
      are not.
    - false: `{{^renderable}}...{{/}}` are rendered, `{{#renderable}}...{{/}}`
      are not.
    
    Example:
    
        class MyRenderable: MustacheRenderable {
            let mustacheBoolValue = true
        }
    
    :returns: Whether the renderable object should trigger the rendering of
    Mustache sections.
    */
    var mustacheBoolValue: Bool { get }
    
    /**
    TODO
    */
    var mustacheTraversable: MustacheTraversable? { get }
    
    /**
    Controls whether the renderable object can be used as a filter.
    
    :returns: An optional filter object that should be applied when the
    renderable object is involved in a filter expression such as
    `renderable(...)`.
    */
    var mustacheFilter: MustacheFilter? { get }
    
    /**
    TODO
    */
    var mustacheTagObserver: MustacheTagObserver? { get }
    
    /**
    TODO
    */
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
}

func MustacheRenderableWithBlock(block: (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)) -> MustacheRenderable {
    return BlockMustacheRenderable(block)
}

private class BlockMustacheRenderable: MustacheRenderable {
    let block: (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)
    
    init(_ block: (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)) {
        self.block = block
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    let mustacheTagObserver: MustacheTagObserver? = nil
    var mustacheTraversable: MustacheTraversable? = nil
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return block(renderingInfo: renderingInfo, outContentType: outContentType, outError: outError)
    }
}