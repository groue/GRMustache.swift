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
    let enumerationItem: Bool
    
    func renderingInfoByExtendingContextWithValue(value: MustacheValue) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingValue(value), enumerationItem: enumerationItem)
    }
    
    func renderingInfoByExtendingContextWithTagObserver(tagObserver: MustacheTagObserver) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingTagObserver(tagObserver), enumerationItem: enumerationItem)
    }
    
    // Should be made protected
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(context: context, enumerationItem: true)
    }
}

protocol MustacheRenderable {
    func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
}

