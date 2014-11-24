//
//  HTMLEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class HTMLEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        switch renderingInfo.tag.type {
        case .Variable:
            return .Success("\(self)", .Text)
        case .Section:
            return renderingInfo.render(renderingInfo.context.contextByAddingTagObserver(self))
        }
    }

    
    // MARK: - MustacheFilter
    
    func mustacheFilterByApplyingArgument(argument: Value) -> MustacheFilter? {
        return nil
    }
    
    func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let string = value.toString() {
            return Value(escapeHTML(string))
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
            return Value({ (renderingInfo: RenderingInfo) -> Rendering in
                let rendering = value.render(renderingInfo)
                switch rendering {
                case .Error:
                    return rendering
                case .Success(let string, let contentType):
                    return .Success(escapeHTML(string), contentType)
                }
            })
        case .Section:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
    }
}
