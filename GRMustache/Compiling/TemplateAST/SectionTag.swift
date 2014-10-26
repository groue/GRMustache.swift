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
    var type: TagType { return .Section }
    
    init(expression: Expression, templateAST: TemplateAST) {
        self.expression = expression
        self.templateAST = templateAST
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        return renderingEngine.renderTemplateAST(templateAST, error: outError)
    }
}