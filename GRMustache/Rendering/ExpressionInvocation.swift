//
//  ExpressionInvocation.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ExpressionInvocation: ExpressionVisitor {
    private let expression: Expression
    private var value: Value
    private var context: Context?
    
    init (expression: Expression) {
        self.value = Value()
        self.expression = expression
    }
    
    enum InvocationResult {
        case Error(NSError)
        case Success(Value)
    }
    func invokeWithContext(context: Context) -> InvocationResult {
        self.context = context
        switch expression.acceptExpressionVisitor(self) {
        case .Success:
            return .Success(value)
        case .Error(let error):
            return .Error(error)
        }
    }
    
    
    // MARK: - ExpressionVisitor
    
    func visit(expression: FilteredExpression) -> ExpressionVisitResult {
        let filterResult = expression.filterExpression.acceptExpressionVisitor(self)
        switch filterResult {
        case .Error:
            return filterResult
        case .Success:
            break
        }
        let filterValue = value
        
        let argumentResult = expression.argumentExpression.acceptExpressionVisitor(self)
        switch argumentResult {
        case .Error:
            return argumentResult
        case .Success:
            break
        }
        let argumentValue = value
        
        if filterValue.isEmpty {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"]))
        } else if let filter: MustacheFilter = filterValue.object() {
            return visit(filter, argumentValue: argumentValue, curried: expression.curried)
        } else {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"]))
        }
    }
    
    func visit(expression: IdentifierExpression) -> ExpressionVisitResult {
        value = context![expression.identifier]
        return .Success
    }
    
    func visit(expression: ImplicitIteratorExpression) -> ExpressionVisitResult {
        value = context!.topMustacheValue
        return .Success
    }
    
    func visit(expression: ScopedExpression) -> ExpressionVisitResult {
        let baseResult = expression.baseExpression.acceptExpressionVisitor(self)
        switch baseResult {
        case .Error:
            return baseResult
        case .Success:
            value = value[expression.identifier]
            return .Success
        }
    }
    
    
    // MARK: - Private
    
    private func visit(filter: MustacheFilter, argumentValue: Value, curried: Bool) -> ExpressionVisitResult {
        if curried {
            if let curriedFilter = filter.mustacheFilterByApplyingArgument(argumentValue) {
                value = Value(curriedFilter)
                return .Success
            } else {
                return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"]))
            }
        } else {
            var filterError: NSError? = nil
            if let filterResult = filter.transformedMustacheValue(argumentValue, error: &filterError) {
                value = filterResult
                return .Success
            } else if let filterError = filterError {
                return .Error(filterError)
            } else {
                // MustacheFilter result is nil, but filter error is not set.
                // Assume a filter coded by a lazy programmer, whose
                // intention is to return the empty value.
                value = Value()
                return .Success
            }
        }
    }
    
}