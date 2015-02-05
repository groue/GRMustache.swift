//
//  Configuration.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public struct Configuration {
    public var contentType: ContentType
    public var baseContext: Context
    public var tagStartDelimiter: String
    public var tagEndDelimiter: String
    
    public init() {
        contentType = .HTML
        baseContext = Context(Box(StandardLibrary()))
        tagStartDelimiter = "{{"
        tagEndDelimiter = "}}"
    }
    
    public static var defaultConfiguration = Configuration()
    
    public mutating func extendBaseContext(box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
}
