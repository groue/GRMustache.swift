//
//  VariableTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class VariableTag: Tag, TemplateASTNode {
    let expression: Expression
    let contentType: ContentType
    let escapesHTML: Bool
    var type: TagType { return .Variable }
    
    init(expression: Expression, contentType: ContentType, escapesHTML: Bool) {
        self.escapesHTML = escapesHTML
        self.contentType = contentType
        self.expression = expression
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        return (rendering: "", contentType: contentType)
    }
}