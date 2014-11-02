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
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return self }
    var mustacheTagObserver: MustacheTagObserver? { return self }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(self)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
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
        case .Section, .InvertedSection:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
    }
}
