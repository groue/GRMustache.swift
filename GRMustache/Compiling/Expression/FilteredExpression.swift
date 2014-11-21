//
//  FilteredExpression.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class FilteredExpression: Expression {
    let filterExpression: Expression
    let argumentExpression: Expression
    let curried: Bool
    
    init(token: TemplateToken?, filterExpression: Expression, argumentExpression: Expression, curried: Bool) {
        self.filterExpression = filterExpression
        self.argumentExpression = argumentExpression
        self.curried = curried
        super.init(token: token)
    }
    
    override func acceptExpressionVisitor(visitor: ExpressionVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    override func isEqual(expression: Expression) -> Bool {
        if let expression = expression as? FilteredExpression {
            return (expression.filterExpression == filterExpression) && (expression.argumentExpression == argumentExpression)
        }
        return false
    }
}