//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
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

protocol MustacheRenderable {
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
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return block(renderingInfo: renderingInfo, outContentType: outContentType, outError: outError)
    }
}