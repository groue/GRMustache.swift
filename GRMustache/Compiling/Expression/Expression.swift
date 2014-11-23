//
//  Expression.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class Expression: Equatable {
    func acceptExpressionVisitor(visitor: ExpressionVisitor) -> ExpressionVisitResult {
        fatalError("Subclass must override")
    }
    
    // Polymorphic support for Equatable
    func isEqual(expression: Expression) -> Bool {
        fatalError("Subclass must override")
    }
}

func ==(lhs: Expression, rhs: Expression) -> Bool {
    return lhs.isEqual(rhs)
}
