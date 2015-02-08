// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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