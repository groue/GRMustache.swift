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
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: renderingInfo.context)
        return renderingEngine.mustacheRendering(templateAST, contentType: outContentType, error: outError)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}