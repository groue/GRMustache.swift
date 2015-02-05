//
//  URLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class URLEscape: MustacheBoxable {
    
    private func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
        }
    }
    
    private func filter(box: Box, error: NSErrorPointer) -> Box? {
        if let string = box.stringValue {
            return boxValue(URLEscape.escapeURL(string))
        } else {
            return Box()
        }
    }
    
    private func willRender(tag: Tag, box: Box) -> Box {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We can not escape `object`, because it is not a string.
            // We want to escape its rendering.
            // So return a rendering object that will eventually render `object`,
            // and escape its rendering.
            return boxValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if let rendering = box.render(info: info, error: error) {
                    return Rendering(URLEscape.escapeURL(rendering.string), rendering.contentType)
                } else {
                    return nil
                }
            })
        case .Section:
            return box
        }
    }
    
    private class func escapeURL(string: String) -> String {
        var s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet
        s.removeCharactersInString("?&=")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(s) ?? ""
    }
    
    
    // MARK: - MustacheBoxable
    
    var mustacheBox: Box {
        return Box(
            value: self,
            render: render,
            filter: Filter(filter),
            willRender: willRender)
    }
}
