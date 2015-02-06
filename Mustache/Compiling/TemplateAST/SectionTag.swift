//
//  SectionTag.swift
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class SectionTag: Tag, TemplateASTNode {
    let openingToken: TemplateToken
    let templateAST: TemplateAST
    
    init(expression: Expression, inverted: Bool, templateAST: TemplateAST, openingToken: TemplateToken, innerTemplateString: String) {
        self.templateAST = templateAST
        self.openingToken = openingToken
        super.init(type: .Section, innerTemplateString: innerTemplateString, inverted: inverted, expression: expression)
    }
    
    override var description: String {
        if let templateID = openingToken.templateID {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber) of template \(templateID)"
        } else {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber)"
        }
    }
    
    override func render(context: Context, error: NSErrorPointer) -> Rendering? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        return renderingEngine.render(templateAST, error: error)
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult {
        return visitor.visit(self)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}