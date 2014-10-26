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
    
    func acceptExpressionVisitor(visitor: ExpressionVisitor, error outError: NSErrorPointer) -> Bool {
        return visitor.visit(self, error: outError)
    }
}
