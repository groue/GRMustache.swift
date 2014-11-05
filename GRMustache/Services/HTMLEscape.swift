//
//  HTMLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class HTMLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return renderingInfo.tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
    }

    
    // MARK: - MustacheFilter
    
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        switch value.type {
        case .None:
            return value
        default:
            if let string = value.asString() {
                return MustacheValue(escapeHTML(string))
            } else {
                if outError != nil {
                    outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not a string"])
                }
                return nil
            }
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
        switch tag.type {
        case .Variable:
            if let string = value.asString() {
                return MustacheValue(escapeHTML(string))
            } else {
                return value
            }
        case .Section:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
    }
}
