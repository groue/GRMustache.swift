//
//  MustacheCluster.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol MustacheCluster: MustacheObject {
    
    /**
    Controls whether the object should trigger or avoid the rendering
    of Mustache sections.
    
    - true: `{{#object}}...{{/}}` are rendered, `{{^object}}...{{/}}`
      are not.
    - false: `{{^object}}...{{/}}` are rendered, `{{#object}}...{{/}}`
      are not.
    
    Example:
    
        class MyObject: MustacheCluster {
            let mustacheBool = true
        }
    
    :returns: Whether the object should trigger the rendering of
    Mustache sections.
    */
    var mustacheBool: Bool { get }
    
    /**
    TODO
    */
    var mustacheTraversable: MustacheTraversable? { get }
    
    /**
    Controls whether the object can be used as a filter.
    
    :returns: An optional filter object that should be applied when the object
    is involved in a filter expression such as `object(...)`.
    */
    var mustacheFilter: MustacheFilter? { get }
    
    /**
    TODO
    */
    var mustacheTagObserver: MustacheTagObserver? { get }
    
    /**
    TODO
    */
    var mustacheRenderable: MustacheRenderable? { get }
}
