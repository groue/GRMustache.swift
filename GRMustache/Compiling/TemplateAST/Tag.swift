//
//  Tag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

enum TagType {
    case Variable
    case Section
    case InvertedSection
}

protocol Tag {
    var expression: Expression { get }
    var type: TagType { get }
    
    func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)?
}
