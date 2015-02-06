//
//  TemplateToken.swift
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
        case SetDelimiters
        case Pragma(content: String)
        case InheritablePartial(content: String)
        case InheritableSection(content: String)
    }
    
    let lineNumber: Int
    let templateString: String
    let range: Range<String.Index>
    let type: Type
    let templateID: TemplateID?
    
    var templateSubstring: String { return templateString[range] }
}
