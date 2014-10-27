//
//  TemplateToken.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

struct TemplateToken {
    enum Type {
        case Text(text: String)
        case EscapedVariable(content: String)
        case UnescapedVariable(content: String)
        case Comment
        case Section(content: String)
        case InvertedSection(content: String)
        case Close(content: String)
        case Partial(content: String)
        case SetDelimiter(content: String)
        case Pragma(content: String)
        case InheritablePartial(content: String)
        case InheritableSection(content: String)
    }
    
    let type: Type
}
