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
        self.value = MustacheValue()
        self.expression = expression
    }
    
    func invokeWithContext(context: Context, error outError: NSErrorPointer) -> Bool {
        self.context = context
        return expression.acceptExpressionVisitor(self, error: outError)
    }
    
    
    // MARK: - ExpressionVisitor
    
    func visit(expression: FilteredExpression, error outError: NSErrorPointer) -> Bool {
        if !expression.filterExpression.acceptExpressionVisitor(self, error: outError) {
            return false
        }
        let filterValue = value
        
        if !expression.argumentExpression.acceptExpressionVisitor(self, error: outError) {
            return false
        }
        let argumentValue = value
        
        switch filterValue.type {
        case .FilterValue(let filter):
            if expression.curried {
                value = MustacheValue(filter.filterByCurryingArgument(argumentValue))
            } else {
                value = filter.transformedValue(argumentValue)
            }
            return true
        case .None:
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"])
            }
            return false
        default:
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"])
            }
            return false
        }
    }
    
    func visit(expression: IdentifierExpression, error outError: NSErrorPointer) -> Bool {
        value = context!.valueForMustacheIdentifier(expression.identifier)
        return true
    }
    
    func visit(expression: ImplicitIteratorExpression, error outError: NSErrorPointer) -> Bool {
        value = context!.topMustacheValue
        return true
    }
    
    func visit(expression: ScopedExpression, error outError: NSErrorPointer) -> Bool {
        if !expression.baseExpression.acceptExpressionVisitor(self, error: outError) {
            return false
        }
        value = value.valueForMustacheIdentifier(expression.identifier)
        return true
    }
}