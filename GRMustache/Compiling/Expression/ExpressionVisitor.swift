//
//  ExpressionVisitor.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

enum ExpressionVisitResult {
    case Error(NSError)
    case Success
}

protocol ExpressionVisitor {
    func visit(expression: FilteredExpression) -> ExpressionVisitResult
    func visit(expression: IdentifierExpression) -> ExpressionVisitResult
    func visit(expression: ImplicitIteratorExpression) -> ExpressionVisitResult
    func visit(expression: ScopedExpression) -> ExpressionVisitResult
}
