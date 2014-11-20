//
//  URLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class URLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
    }

    
    // MARK: - MustacheFilter
    
    func mustacheFilterByApplyingArgument(argument: Value) -> MustacheFilter? {
        return nil
    }
    
    func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let string = value.toString() {
            return Value(escapeURL(string))
        } else {
            return Value()
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We can not escape `object`, because it is not a string.
            // We want to escape its rendering.
            // So return a rendering object that will eventually render `object`,
            // and escape its rendering.
            return Value({ (tag: Tag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
                if let rendering = value.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: contentType, error: error) {
                    return self.escapeURL(rendering)
                } else {
                    return nil
                }
            })
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
