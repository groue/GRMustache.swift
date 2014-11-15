//
//  ExpressionVisitor.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

protocol ExpressionVisitor {
    func visit(expression: FilteredExpression, error outError: NSErrorPointer) -> Bool
    func visit(expression: IdentifierExpression, error outError: NSErrorPointer) -> Bool
    func visit(expression: ImplicitIteratorExpression, error outError: NSErrorPointer) -> Bool
    func visit(expression: ScopedExpression, error outError: NSErrorPointer) -> Bool
}