//
//  MustacheCluster.swift
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

protocol MustacheCluster {
    
    /**
    Controls whether the object should trigger or avoid the rendering
    of Mustache sections.
    
    - true: `{{#object}}...{{/}}` are rendered, `{{^object}}...{{/}}`
      are not.
    - false: `{{^object}}...{{/}}` are rendered, `{{#object}}...{{/}}`
      are not.
    
    Example:
    
        class MyObject: MustacheCluster {
            let mustacheBoolValue = true
        }
    
    :returns: Whether the object should trigger the rendering of
    Mustache sections.
    */
    var mustacheBoolValue: Bool { get }
    
    /**
    TODO
    */
    var mustacheTraversable: MustacheTraversable? { get }
    
    /**
    Controls whether the object can be used as a filter.
    
    :returns: An optional filter object that should be applied when the object
    is involved in a filter expression such as `object(...)`.
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

func MustacheClusterWithBlock(block: (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)) -> MustacheCluster {
    return BlockMustacheCluster(block)
}

private class BlockMustacheCluster: MustacheCluster {
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