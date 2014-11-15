//
//  Renderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public struct RenderingInfo {
    public let context: Context
    let enumerationItem: Bool
    
    public func renderingInfoByExtendingContextWithValue(value: Value) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingValue(value), enumerationItem: enumerationItem)
    }
    
    public func renderingInfoByExtendingContextWithTagObserver(tagObserver: TagObserver) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingTagObserver(tagObserver), enumerationItem: enumerationItem)
    }
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(context: context, enumerationItem: true)
    }
}

public protocol Renderable {
    func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
}

