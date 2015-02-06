//
//  TemplateASTVisitor.swift
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

enum TemplateASTVisitResult {
    case Error(NSError)
    case Success
}

protocol TemplateASTVisitor {
    func visit(inheritablePartialNode: InheritablePartialNode) -> TemplateASTVisitResult
    func visit(inheritableSectionNode: InheritableSectionNode) -> TemplateASTVisitResult
    func visit(partialNode: PartialNode) -> TemplateASTVisitResult
    func visit(variableTag: VariableTag) -> TemplateASTVisitResult
    func visit(sectionTag: SectionTag) -> TemplateASTVisitResult
    func visit(textNode: TextNode) -> TemplateASTVisitResult
}