//
//  ExpressionInvocation.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ExpressionInvocation: ExpressionVisitor {
    private let expression: Expression
    private var box: Box
    private var context: Context?
    
    init (expression: Expression) {
        self.box = Box()
        self.expression = expression
    }
    
    enum InvocationResult {
        case Error(NSError)
        case Success(Box)
    }
    func invokeWithContext(context: Context) -> InvocationResult {
        self.context = context
        switch expression.acceptExpressionVisitor(self) {
        case .Success:
            return .Success(box)
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
        let boxedFilter = box
        
        let argumentResult = expression.argumentExpression.acceptExpressionVisitor(self)
        switch argumentResult {
        case .Error:
            return argumentResult
        case .Success:
            break
        }
        let boxedArgument = box
        
        if boxedFilter.isEmpty {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"]))
        } else if let filter: MustacheFilter = boxedFilter.value() {
            return visit(filter, boxedArgument: boxedArgument, curried: expression.curried)
        } else {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"]))
        }
    }
    
    func visit(expression: IdentifierExpression) -> ExpressionVisitResult {
        box = context![expression.identifier]
        return .Success
    }
    
    func visit(expression: ImplicitIteratorExpression) -> ExpressionVisitResult {
        box = context!.topBoxedValue
        return .Success
    }
    
    func visit(expression: ScopedExpression) -> ExpressionVisitResult {
        let baseResult = expression.baseExpression.acceptExpressionVisitor(self)
        switch baseResult {
        case .Error:
            return baseResult
        case .Success:
            box = box[expression.identifier]
            return .Success
        }
    }
    
    
    // MARK: - Private
    
    private func visit(filter: MustacheFilter, boxedArgument: Box, curried: Bool) -> ExpressionVisitResult {
        if curried {
            if let curriedFilter = filter.mustacheFilterByApplyingArgument(boxedArgument) {
                box = Box(curriedFilter)
                return .Success
            } else {
                return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"]))
            }
        } else {
            var filterError: NSError? = nil
            if let filterResult = filter.transformedMustacheValue(boxedArgument, error: &filterError) {
                box = filterResult
                return .Success
            } else if let filterError = filterError {
                return .Error(filterError)
            } else {
                // MustacheFilter result is nil, but filter error is not set.
                // Assume a filter coded by a lazy programmer, whose
                // intention is to return the empty value.
                box = Box()
                return .Success
            }
        }
    }
    
}