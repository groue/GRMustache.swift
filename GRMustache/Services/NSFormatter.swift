//
//  NSFormatter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 19/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

extension NSFormatter: MustacheFilter, MustacheRenderable, MustacheTagObserver {
    
    
    // MARK: - MustacheFilter
    
    public func mustacheFilterByApplyingArgument(argument: Value) -> MustacheFilter? {
        return nil
    }
    
    public func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let object: AnyObject = value.object() {
            return Value(self.stringForObjectValue(object))
        } else {
            return Value()
        }
    }
    
    
    // MARK: - MustacheRenderable
    
    public func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch renderingInfo.tag.type {
        case .Variable:
            // {{ formatter }}
            // Behave as a regular object: render self's description
            return Rendering("\(self)")
        case .Section:
            // {{# formatter }}...{{/ formatter }}
            // {{^ formatter }}...{{/ formatter }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            return renderingInfo.render(renderingInfo.context.contextByAddingTagObserver(self), error: error)
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    public func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        switch tag.type {
        case .Variable:
            // {{ value }}
            
            if let object: AnyObject = value.object() {
                // NSFormatter documentation for stringForObjectValue: states:
                //
                // > First test the passed-in object to see if it’s of the correct
                // > class. If it isn’t, return nil; but if it is of the right class,
                // > return a properly formatted and, if necessary, localized string.
                //
                // So nil result means that object is not of the correct class. Leave
                // it untouched.
                
                if let formatted = self.stringForObjectValue(object) {
                    return Value(formatted)
                }
            }
            return value
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            return value
        }
    }
    
    public func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
        
    }
}
