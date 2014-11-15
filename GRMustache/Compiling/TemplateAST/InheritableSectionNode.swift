//
//  InheritableSectionNode.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class InheritableSectionNode: TemplateASTNode {
    let name: String
    let templateAST: TemplateAST
    
    init(name: String, templateAST: TemplateAST) {
        self.name = name
        self.templateAST = templateAST
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        if let node = node as? InheritableSectionNode {
            if node.name == name {
                return self
            } else {
                return node
            }
        } else {
            return node
        }
    }
}