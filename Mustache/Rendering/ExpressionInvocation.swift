//
//  ExpressionInvocation.swift
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ExpressionInvocation: ExpressionVisitor {
    private let expression: Expression
    private var result: MustacheBox
    private var context: Context?
    
    init (expression: Expression) {
        self.result = Box()
        self.expression = expression
    }
    
    enum InvocationResult {
        case Error(NSError)
        case Success(MustacheBox)
    }
    
    func invokeWithContext(context: Context) -> InvocationResult {
        self.context = context
        switch expression.acceptExpressionVisitor(self) {
        case .Success:
            return .Success(result)
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
        let filterBox = result
        
        let argumentResult = expression.argumentExpression.acceptExpressionVisitor(self)
        switch argumentResult {
        case .Error:
            return argumentResult
        case .Success:
            break
        }
        let argumentBox = result
        
        if let filter = filterBox.filter {
            var filterError: NSError? = nil
            if let filterResult = filter(box: argumentBox, partialApplication: expression.partialApplication, error: &filterError) {
                result = filterResult
                return .Success
            } else if let filterError = filterError {
                return .Error(filterError)
            } else {
                // MustacheFilter result is nil, but filter error is not set.
                // Assume a filter coded by a lazy programmer, whose
                // intention is to return the empty value.
                result = Box()
                return .Success
            }
        } else if filterBox.isEmpty {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"]))
        } else {
            return .Error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"]))
        }
    }
    
    func visit(expression: IdentifierExpression) -> ExpressionVisitResult {
        result = context![expression.identifier]
        return .Success
    }
    
    func visit(expression: ImplicitIteratorExpression) -> ExpressionVisitResult {
        result = context!.topBox
        return .Success
    }
    
    func visit(expression: ScopedExpression) -> ExpressionVisitResult {
        let baseResult = expression.baseExpression.acceptExpressionVisitor(self)
        switch baseResult {
        case .Error:
            return baseResult
        case .Success:
            result = result[expression.identifier]
            return .Success
        }
    }   
}