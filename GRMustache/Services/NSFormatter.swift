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
    
    public func mustacheFilterByApplyingArgument(argument: Box) -> MustacheFilter? {
        return nil
    }
    
    public func transformedMustacheValue(box: Box, error: NSErrorPointer) -> Box? {
        if let object: AnyObject = box.value() {
            return Box(self.stringForObjectValue(object))
        } else {
            return Box()
        }
    }
    
    
    // MARK: - MustacheRenderable
    
    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            // {{ formatter }}
            // Behave as a regular object: render self's description
            return Rendering("\(self)")
        case .Section:
            // {{# formatter }}...{{/ formatter }}
            // {{^ formatter }}...{{/ formatter }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            return info.tag.render(info.context.extendedContext(tagObserver: self), error: error)
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    public func mustacheTag(tag: Tag, willRender box: Box) -> Box {
        switch tag.type {
        case .Variable:
            // {{ value }}
            
            if let object: AnyObject = box.value() {
                // NSFormatter documentation for stringForObjectValue: states:
                //
                // > First test the passed-in object to see if it’s of the correct
                // > class. If it isn’t, return nil; but if it is of the right class,
                // > return a properly formatted and, if necessary, localized string.
                //
                // So nil result means that object is not of the correct class. Leave
                // it untouched.
                
                if let formatted = self.stringForObjectValue(object) {
                    return Box(formatted)
                }
            }
            return box
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            return box
        }
    }
    
    public func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
        
    }
}
