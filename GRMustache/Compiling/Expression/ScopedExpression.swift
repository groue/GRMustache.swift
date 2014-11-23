//
//  ScopedExpression.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ScopedExpression: Expression {
    let baseExpression: Expression
    let identifier: String
    
    init(baseExpression: Expression, identifier: String) {
        self.baseExpression = baseExpression
        self.identifier = identifier
    }
    
    override func acceptExpressionVisitor(visitor: ExpressionVisitor) -> ExpressionVisitResult {
        return visitor.visit(self)
    }
    
    override func isEqual(expression: Expression) -> Bool {
        if let expression = expression as? ScopedExpression {
            return (expression.baseExpression == baseExpression) && (expression.identifier == identifier)
        }
        return false
    }
}