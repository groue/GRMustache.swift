//
//  VariableTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class VariableTag: MustacheExpressionTag, TemplateASTNode {
    let token: TemplateToken
    let expression: Expression
    let contentType: ContentType
    let escapesHTML: Bool
    var type: TagType { return .Variable }
    let innerTemplateString = ""
    let inverted = true
    var description: String {
        if let templateID = token.templateID {
            return "\(token.templateSubstring) at line \(token.lineNumber) of template \(templateID)"
        } else {
            return "\(token.templateSubstring) at line \(token.lineNumber)"
        }
    }
    
    init(expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) {
        self.escapesHTML = escapesHTML
        self.contentType = contentType
        self.expression = expression
        self.token = token
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult {
        return visitor.visit(self)
    }
    
    func render(context: Context, error: NSErrorPointer) -> Rendering? {
        return Rendering("", contentType)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}