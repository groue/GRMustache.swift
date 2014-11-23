//
//  Tag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

public enum TagType {
    case Variable
    case Section
}

public protocol Tag: Printable {
    var type: TagType { get }
    var innerTemplateString: String { get }
    var inverted: Bool { get } // this should be internal
    func render(context: Context) -> Rendering // this should be internal
}

protocol MustacheExpressionTag: Tag {
    var expression: Expression { get }
}