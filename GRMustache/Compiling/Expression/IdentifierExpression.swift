//
//  IdentifierExpression.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class IdentifierExpression: Expression {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    override func acceptExpressionVisitor(visitor: ExpressionVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
    
    override func isEqual(expression: Expression) -> Bool {
        if let expression = expression as? IdentifierExpression {
            return expression.identifier == identifier
        }
        return false
    }
}
