//
//  FilteredExpression.swift
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class FilteredExpression: Expression {
    let filterExpression: Expression
    let argumentExpression: Expression
    let partialApplication: Bool
    
    init(filterExpression: Expression, argumentExpression: Expression, partialApplication: Bool) {
        self.filterExpression = filterExpression
        self.argumentExpression = argumentExpression
        self.partialApplication = partialApplication
    }
    
    override func acceptExpressionVisitor(visitor: ExpressionVisitor) -> ExpressionVisitResult {
        return visitor.visit(self)
    }
    
    override func isEqual(expression: Expression) -> Bool {
        if let expression = expression as? FilteredExpression {
            return (expression.filterExpression == filterExpression) && (expression.argumentExpression == argumentExpression)
        }
        return false
    }
}