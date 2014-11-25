//
//  Tag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

// For some reason, declaring a Type enum inside the Tag class prevents
// variables to be declared as Tag.Type.
// So let's use a `TagType` type instead.
public enum TagType {
    case Variable
    case Section
}
    
public class Tag: Printable {
    public let type: TagType
    public let innerTemplateString: String
    var inverted: Bool
    var expression: Expression
    
    init(type: TagType, innerTemplateString: String, inverted: Bool, expression: Expression) {
        self.type = type
        self.innerTemplateString = innerTemplateString
        self.inverted = inverted
        self.expression = expression
    }
    
    public func render(context: Context, error: NSErrorPointer = nil) -> Rendering? {
        fatalError("Subclass must override")
    }
    
    public var description: String {
        fatalError("Subclass must override")
    }
}
