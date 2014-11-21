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
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func renderContent(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        if outContentType != nil {
            outContentType.memory = contentType
        }
        return ""
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}