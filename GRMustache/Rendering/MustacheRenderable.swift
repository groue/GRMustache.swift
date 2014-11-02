//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct RenderingOptions {
    let enumerationItem: Bool
}

protocol MustacheTagObserver {
    func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue
    
    // If rendering is nil then an error has occurred.
    func mustacheTag(tag: Tag, didRender rendering: MustacheRendering?, forValue: MustacheValue)
}

protocol MustacheRenderable {
    
    /**
    Controls whether the renderable object should trigger or avoid the rendering
    of Mustache sections.
    
    - true: `{{#renderable}}...{{/}}` are rendered, `{{^renderable}}...{{/}}`
      are not.
    - false: `{{^renderable}}...{{/}}` are rendered, `{{#renderable}}...{{/}}`
      are not.
    
    Example:
    
        class MyRenderable: MustacheRenderable {
            let mustacheBoolValue = true
        }
    
    :returns: Whether the renderable object should trigger the rendering of
    Mustache sections.
    */
    var mustacheBoolValue: Bool { get }
    
    /**
    Controls whether the renderable object can be used as a filter.
    
    :returns: An optional filter object that should be applied when the
    renderable object is involved in a filter expression such as
    `renderable(...)`.
    */
    var mustacheFilter: MustacheFilter? { get }
    
    /**
    TODO
    */
    var mustacheTagObserver: MustacheTagObserver? { get }
    
    /**
    TODO
    */
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue?
    
    /**
    TODO
    */
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering?
}

func MustacheRenderableWithBlock(block: (tag: Tag, context: Context, options: RenderingOptions, error: NSErrorPointer) -> (MustacheRendering?)) -> MustacheRenderable {
    return BlockMustacheRenderable(block)
}

private class BlockMustacheRenderable: MustacheRenderable {
    let block: (tag: Tag, context: Context, options: RenderingOptions, error: NSErrorPointer) -> (MustacheRendering?)
    
    init(_ block: (tag: Tag, context: Context, options: RenderingOptions, error: NSErrorPointer) -> (MustacheRendering?)) {
        self.block = block
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    let mustacheTagObserver: MustacheTagObserver? = nil
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
        return block(tag: tag, context: context, options: options, error: outError)
    }
}