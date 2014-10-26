//
//  ExpressionInvocation.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class ExpressionInvocation: ExpressionVisitor {
    let expression: Expression
    var value: MustacheValue
    private var context: Context?
    
    init (expression: Expression) {
        self.value = .None
        self.expression = expression
    }
    
    func invokeWithContext(context: Context, error outError: NSErrorPointer) -> Bool {
        self.context = context
        return expression.acceptExpressionVisitor(self, error: outError)
    }
    
    
    // MARK: - ExpressionVisitor
    
    func visit(expression: IdentifierExpression, error outError: NSErrorPointer) -> Bool {
        value = context!.valueForMustacheIdentifier(expression.identifier)
        return true
    }
}