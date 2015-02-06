//
//  VariableTag.swift
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class VariableTag: Tag, TemplateASTNode {
    let token: TemplateToken
    let contentType: ContentType
    let escapesHTML: Bool
    
    init(expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) {
        self.escapesHTML = escapesHTML
        self.contentType = contentType
        self.token = token
        super.init(type: .Variable, innerTemplateString: "", inverted: false, expression: expression)
    }
    
    override var description: String {
        if let templateID = token.templateID {
            return "\(token.templateSubstring) at line \(token.lineNumber) of template \(templateID)"
        } else {
            return "\(token.templateSubstring) at line \(token.lineNumber)"
        }
    }
    
    override func render(context: Context, error: NSErrorPointer) -> Rendering? {
        return Rendering("", contentType)
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult {
        return visitor.visit(self)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}