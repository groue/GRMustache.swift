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


import Foundation

final class ExpressionInvocation {
    private let expression: Expression
    private var result: MustacheBox
    private var context: Context?
    
    init (expression: Expression) {
        self.result = Box()
        self.expression = expression
    }
    
    enum InvocationResult {
        case Success(MustacheBox)
        case Error(NSError)
    }
    
    func invokeWithContext(context: Context) -> InvocationResult {
        self.context = context
        if let error = evaluate(expression) {
            return .Error(error)
        } else {
            return .Success(result)
        }
    }
    
    // On error, return an error
    // On success, self.result is the evaluation of the expression
    private func evaluate(expression: Expression) -> NSError? {
        switch expression {
        case .ImplicitIterator:
            // {{ . }}
            
            result = context!.topBox
            return nil
            
        case .Identifier(let identifier):
            // {{ identifier }}
            
            result = context![identifier]
            return nil

        case .Scoped(let baseExpression, let identifier):
            // {{ <expression>.identifier }}
            
            if let error = evaluate(baseExpression.expression) {
                return error
            } else {
                result = result[identifier]
                return nil
            }
            
        case .Filter(let filterExpression, let argumentExpression, let partialApplication):
            // {{ <expression>(<expression>) }}
            
            if let error = evaluate(filterExpression.expression) {
                return error
            }
            let filterBox = result
            
            if let error = evaluate(argumentExpression.expression) {
                return error
            }
            let argumentBox = result
            
            if let filter = filterBox.filter {
                var filterError: NSError? = nil
                if let filterResult = filter(box: argumentBox, partialApplication: partialApplication, error: &filterError) {
                    result = filterResult
                    return nil
                } else if let filterError = filterError {
                    return filterError
                } else {
                    // MustacheFilter result is nil, but filter error is not set.
                    // Assume a filter coded by a lazy programmer, whose
                    // intention is to return the empty value.
                    result = Box()
                    return nil
                }
            } else if filterBox.isEmpty {
                return NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Missing filter"])
            } else {
                return NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"])
            }
        }
    }
}