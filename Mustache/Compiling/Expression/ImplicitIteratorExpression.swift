//
//  ImplicitIteratorExpression.swift
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ImplicitIteratorExpression: Expression {
    
    override func acceptExpressionVisitor(visitor: ExpressionVisitor) -> ExpressionVisitResult {
        return visitor.visit(self)
    }
    
    override func isEqual(expression: Expression) -> Bool {
        return expression is ImplicitIteratorExpression
    }
}