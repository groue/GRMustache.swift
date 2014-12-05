//
//  URLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class URLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            return info.tag.render(info.context.extendedContext(tagObserver: self), error: error)
        }
    }

    
    // MARK: - MustacheFilter
    
    func mustacheFilterByApplyingArgument(argument: Box) -> MustacheFilter? {
        return nil
    }
    
    func transformedMustacheValue(box: Box, error: NSErrorPointer) -> Box? {
        if let string = box.toString() {
            return Box(URLEscape.escapeURL(string))
        } else {
            return Box()
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: Tag, willRender box: Box) -> Box {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We can not escape `object`, because it is not a string.
            // We want to escape its rendering.
            // So return a rendering object that will eventually render `object`,
            // and escape its rendering.
            return BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if let rendering = box.render(info, error: error) {
                    return Rendering(URLEscape.escapeURL(rendering.string), rendering.contentType)
                } else {
                    return nil
                }
            })
        case .Section:
            return box
        }
    }
    
    func mustacheTag(tag: Tag, didRender box: Box, asString: String?) {
    }
    
    
    // MARK: - private
    
    private class func escapeURL(string: String) -> String {
        var s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet
        s.removeCharactersInString("?&=")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(s) ?? ""
    }
}
