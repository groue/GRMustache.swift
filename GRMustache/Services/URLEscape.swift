//
//  URLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class URLEscape: Renderable, Filter, TagObserver {
    
    
    // MARK: - Renderable
    
    func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
    }

    
    // MARK: - Filter
    
    func mustacheFilterByApplyingArgument(argument: Value) -> Filter? {
        return nil
    }
    
    func transformedMustacheValue(value: Value, error outError: NSErrorPointer) -> Value? {
        if let string = value.toString() {
            return Value(escapeURL(string))
        } else {
            return Value()
        }
    }
    
    
    // MARK: - TagObserver
    
    func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        switch tag.type {
        case .Variable:
            if let string = value.toString() {
                return Value(escapeURL(string))
            } else {
                return value
            }
        case .Section:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
    }
    
    
    // MARK: - private
    
    private func escapeURL(string: String) -> String {
        var s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet
        s.removeCharactersInString("?&=")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(s) ?? ""
    }
}
