//
//  SectionTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class SectionTag: MustacheExpressionTag, TemplateASTNode {
    let expression: Expression
    let templateAST: TemplateAST
    let inverted: Bool
    let type: TagType = .Section
    let innerTemplateString: String
    var description: String {
        if let token = expression.token {
            if let templateID = token.templateID {
                return "<SectionTag \(token.templateSubstring) at line \(token.lineNumber) of template \(templateID)>"
            } else {
                return "<SectionTag \(token.templateSubstring) at line \(token.lineNumber)>"
            }
        } else {
            return "<SectionTag>"
        }
    }
    
    init(expression: Expression, inverted: Bool, templateAST: TemplateAST, innerTemplateString: String) {
        self.expression = expression
        self.inverted = inverted
        self.templateAST = templateAST
        self.innerTemplateString = innerTemplateString
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func renderContent(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: renderingInfo.context)
        return renderingEngine.render(templateAST, contentType: outContentType, error: outError)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}