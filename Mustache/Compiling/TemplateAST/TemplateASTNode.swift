//
//  TemplateASTNode.swift
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

protocol TemplateASTNode: class {
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode
}
