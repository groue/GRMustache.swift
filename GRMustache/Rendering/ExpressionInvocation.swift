//
//  ExpressionInvocation.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ExpressionInvocation: ExpressionVisitor {
    private let expression: Expression
    var value: Value
    private var context: Context?
    
    init (expression: Expression) {
        self.value = Value()
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
        
        if filterValue.isEmpty {
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"])
            }
            return false
        } else if let filter: Filter = filterValue.object() {
            return visit(filter, argumentValue: argumentValue, curried: expression.curried, error: outError)
        } else {
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"])
            }
            return false
        }
    }
    
    func visit(expression: IdentifierExpression, error outError: NSErrorPointer) -> Bool {
        value = context![expression.identifier]
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
        value = value[expression.identifier]
        return true
    }
    
    
    // MARK: - Private
    
    private func visit(filter: Filter, argumentValue: Value, curried: Bool, error outError: NSErrorPointer) -> Bool {
        if curried {
            if let curriedFilter = filter.mustacheFilterByApplyingArgument(argumentValue) {
                value = Value(curriedFilter)
            } else {
                if outError != nil {
                    outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
                }
                return false
            }
        } else {
            var filterError: NSError? = nil
            if let filterResult = filter.transformedMustacheValue(argumentValue, error: &filterError) {
                value = filterResult
            } else if let filterError = filterError {
                if outError != nil {
                    outError.memory = filterError
                }
                return false
            } else {
                // Filter result is nil, but filter error is not set.
                // Assume a filter coded by a lazy programmer, whose
                // intention is to return the empty value.
                
                value = Value()
            }
        }
        return true
    }
    
}