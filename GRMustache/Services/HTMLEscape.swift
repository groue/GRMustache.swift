//
//  HTMLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class HTMLEscape {
    
    private func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            return info.tag.render(info.context.extendedContext(Box(self)), error: error)
        }
    }
    
    private func filter(box: Box, error: NSErrorPointer) -> Box? {
        if let string = box.stringValue {
            return Box(escapeHTML(string))
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
            return Box(render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if let rendering = box.render(info: info, error: error) {
                    return Rendering(escapeHTML(rendering.string), rendering.contentType)
                } else {
                    return nil
                }
            })
        case .Section:
            return box
        }
    }
}

extension Box {
    init(_ formatter: HTMLEscape) {
        self.init(
            value: formatter,
            render: formatter.render,
            filter: Filter(formatter.filter),
            willRender: formatter.willRender)
    }
}
