//
//  SectionTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class SectionTag: Tag, TemplateASTNode {
    let expression: Expression
    let templateAST: TemplateAST
    let inverted: Bool
    var type: TagType { return inverted ? .InvertedSection : .Section }
    
    init(expression: Expression, inverted: Bool, templateAST: TemplateAST) {
        self.expression = expression
        self.inverted = inverted
        self.templateAST = templateAST
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        return renderingEngine.renderTemplateAST(templateAST, error: outError)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}