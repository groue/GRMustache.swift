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

/**
The type for expressions that appear in tags: `name`, `user.name`,
`uppercase(user.name)`, etc.

Expression conforms to Equatable so that the Compiler can check that section
tags have matching openings and closings: {{# person }}...{{/ person }} is OK
but {{# foo }}...{{/ bar }} is not.
*/
enum Expression: Equatable {
    // {{ . }}
    case ImplicitIterator

    // {{ identifier }}
    case Identifier(identifier: String)
    
    // {{ <expression>.identifier }}
    case Scoped(baseExpression: ExpressionWrapper, identifier: String)
    
    // {{ <expression>(<expression>) }}
    case Filter(filterExpression: ExpressionWrapper, argumentExpression: ExpressionWrapper, partialApplication: Bool)
    
    
    // For the sake of brevity
    init(identifier: String) {
        self = .Identifier(identifier: identifier)
    }
    
    // For the sake of brevity
    init(baseExpression: Expression, identifier: String) {
        self = .Scoped(baseExpression: ExpressionWrapper(baseExpression), identifier: identifier)
    }
    
    // For the sake of brevity
    init(filterExpression: Expression, argumentExpression: Expression, partialApplication: Bool) {
        self = .Filter(filterExpression: ExpressionWrapper(filterExpression), argumentExpression: ExpressionWrapper(argumentExpression), partialApplication: partialApplication)
    }
    
    
    // Recursive enums need wrapper class
    class ExpressionWrapper {
        let expression: Expression
        init(_ expression: Expression) {
            self.expression = expression
        }
    }
}

func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case (.ImplicitIterator, .ImplicitIterator):
        return true
        
    case (.Identifier(let lIdentifier), .Identifier(let rIdentifier)):
        return lIdentifier == rIdentifier
        
    case (.Scoped(let lBase, let lIdentifier), .Scoped(let rBase, let rIdentifier)):
        return lBase.expression == rBase.expression && lIdentifier == rIdentifier
        
    case (.Filter(let lFilter, let lArgument, let lPartialApplication), .Filter(let rFilter, let rArgument, let rPartialApplication)):
        return lFilter.expression == rFilter.expression && lArgument.expression == rArgument.expression && lPartialApplication == rPartialApplication
        
    default:
        return false
    }
}
