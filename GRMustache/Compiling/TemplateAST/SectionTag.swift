//
//  SectionTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class SectionTag: MustacheExpressionTag, TemplateASTNode {
    let openingToken: TemplateToken
    let expression: Expression
    let templateAST: TemplateAST
    let inverted: Bool
    let type: TagType = .Section
    let innerTemplateString: String
    var description: String {
        if let templateID = openingToken.templateID {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber) of template \(templateID)"
        } else {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber)"
        }
    }
    
    init(expression: Expression, inverted: Bool, templateAST: TemplateAST, openingToken: TemplateToken, innerTemplateString: String) {
        self.expression = expression
        self.inverted = inverted
        self.templateAST = templateAST
        self.openingToken = openingToken
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