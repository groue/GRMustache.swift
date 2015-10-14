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

final class ExpressionParser {
    
    func parse(string: String, inout empty outEmpty: Bool) throws -> Expression {
        enum State {
            // error
            case Error(String)
            
            // Any expression can start
            case WaitingForAnyExpression
            
            // Expression has started with a dot
            case LeadingDot
            
            // Expression has started with an identifier
            case Identifier(identifierStart: String.Index)
            
            // Parsing a scoping identifier
            case ScopingIdentifier(identifierStart: String.Index, baseExpression: Expression)
            
            // Waiting for a scoping identifier
            case WaitingForScopingIdentifier(baseExpression: Expression)
            
            // Parsed an expression
            case DoneExpression(expression: Expression)
            
            // Parsed white space after an expression
            case DoneExpressionPlusWhiteSpace(expression: Expression)
        }
        
        var state: State = .WaitingForAnyExpression
        var filterExpressionStack: [Expression] = []
        
        var i = string.startIndex
        let end = string.endIndex
        stringLoop: while i < end {
            let c = string[i]
            
            switch state {
            case .Error:
                break stringLoop
                
            case .WaitingForAnyExpression:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .LeadingDot
                case "(", ")", ",", "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                default:
                    state = .Identifier(identifierStart: i)
                }
                
            case .LeadingDot:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .DoneExpressionPlusWhiteSpace(expression: Expression.ImplicitIterator)
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case "(":
                    filterExpressionStack.append(Expression.ImplicitIterator)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                default:
                    state = .ScopingIdentifier(identifierStart: i, baseExpression: Expression.ImplicitIterator)
                }
                
            case .Identifier(identifierStart: let identifierStart):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    state = .DoneExpressionPlusWhiteSpace(expression: Expression.Identifier(identifier: identifier))
                case ".":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    state = .WaitingForScopingIdentifier(baseExpression: Expression.Identifier(identifier: identifier))
                case "(":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    filterExpressionStack.append(Expression.Identifier(identifier: identifier))
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.Identifier(identifier: identifier), partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.Identifier(identifier: identifier), partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                default:
                    break
                }
                
            case .ScopingIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .DoneExpressionPlusWhiteSpace(expression: scopedExpression)
                case ".":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .WaitingForScopingIdentifier(baseExpression: scopedExpression)
                case "(":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    filterExpressionStack.append(scopedExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                default:
                    break
                }
                
            case .WaitingForScopingIdentifier(let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .Error("Unexpected white space character at index \(string.startIndex.distanceTo(i))")
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case "(":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case ")":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case ",":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                default:
                    state = .ScopingIdentifier(identifierStart: i, baseExpression: baseExpression)
                }
                
            case .DoneExpression(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .DoneExpressionPlusWhiteSpace(expression: doneExpression)
                case ".":
                    state = .WaitingForScopingIdentifier(baseExpression: doneExpression)
                case "(":
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                default:
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                }
                
            case .DoneExpressionPlusWhiteSpace(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    // Prevent "a .b"
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                case "(":
                    // Accept "a (b)"
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    // Accept "a(b )"
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                case ",":
                    // Accept "a(b ,c)"
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                    }
                default:
                    state = .Error("Unexpected character `\(c)` at index \(string.startIndex.distanceTo(i))")
                }
            }
            
            i = i.successor()
        }
        
        
        // Parsing done
        
        enum FinalState {
            case Error(String)
            case Empty
            case Valid(expression: Expression)
        }
        
        let finalState: FinalState
        
        switch state {
        case .WaitingForAnyExpression:
            if filterExpressionStack.isEmpty {
                finalState = .Empty
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .LeadingDot:
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: Expression.ImplicitIterator)
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .Identifier(identifierStart: let identifierStart):
            if filterExpressionStack.isEmpty {
                let identifier = string.substringFromIndex(identifierStart)
                finalState = .Valid(expression: Expression.Identifier(identifier: identifier))
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .ScopingIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
            if filterExpressionStack.isEmpty {
                let identifier = string.substringFromIndex(identifierStart)
                let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                finalState = .Valid(expression: scopedExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .WaitingForScopingIdentifier:
            finalState = .Error("Missing identifier at index \(string.startIndex.distanceTo(string.endIndex))")
            
        case .DoneExpression(let doneExpression):
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: doneExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .DoneExpressionPlusWhiteSpace(let doneExpression):
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: doneExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(string.startIndex.distanceTo(string.endIndex))")
            }
            
        case .Error(let message):
            finalState = .Error(message)
        }
        
        
        // End
        
        switch finalState {
        case .Empty:
            outEmpty = true
            throw MustacheError(kind: .ParseError, message: "Missing expression")
            
        case .Error(let description):
            outEmpty = false
            throw MustacheError(kind: .ParseError, message: "Invalid expression `\(string)`: \(description)")
            
        case .Valid(expression: let expression):
            return expression
        }
    }
}
