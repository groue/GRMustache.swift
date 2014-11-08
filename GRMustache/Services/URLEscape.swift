//
//  URLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class URLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
    }

    
    // MARK: - MustacheFilter
    
    func filterWithAppliedArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        switch value.type {
        case .None:
            return value
        default:
            if let string = value.string() {
                return MustacheValue(escapeURL(string))
            } else {
                if outError != nil {
                    outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not a string"])
                }
                return nil
            }
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
        switch tag.type {
        case .Variable:
            if let string = value.string() {
                return MustacheValue(escapeURL(string))
            } else {
                return value
            }
        case .Section:
            return value
        }
    }
    
    func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
    }
    
    
    // MARK: - private
    
    func escapeURL(string: String) -> String {
        var s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet
        s.removeCharactersInString("?&=")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(s) ?? ""
    }
}
