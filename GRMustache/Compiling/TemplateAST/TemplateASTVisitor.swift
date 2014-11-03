//
//  TemplateASTVisitor.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol TemplateASTVisitor {
    func visit(inheritablePartialNode: InheritablePartialNode, error outError: NSErrorPointer) -> Bool
    func visit(inheritableSectionNode: InheritableSectionNode, error outError: NSErrorPointer) -> Bool
    func visit(partialNode: PartialNode, error outError: NSErrorPointer) -> Bool
    func visit(variableTag: VariableTag, error outError: NSErrorPointer) -> Bool
    func visit(sectionTag: SectionTag, error outError: NSErrorPointer) -> Bool
    func visit(textNode: TextNode, error outError: NSErrorPointer) -> Bool
}