//
//  MustacheConfiguration.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct MustacheConfiguration {
    var contentType: ContentType
    var baseContext: Context
    var tagStartDelimiter: String
    var tagEndDelimiter: String
    
    init() {
        contentType = .HTML
        baseContext = Context(MustacheValue(StandardLibrary()))
        tagStartDelimiter = "{{"
        tagEndDelimiter = "}}"
    }
    
    static var defaultConfiguration = MustacheConfiguration()
    
    mutating func extendingBaseContextWithValue(value: MustacheValue) {
        baseContext = baseContext.contextByAddingValue(value)
    }
    
    mutating func extendingBaseContextWithTagObserver(tagObserver: MustacheTagObserver) {
        baseContext = baseContext.contextByAddingTagObserver(tagObserver)
    }
}
