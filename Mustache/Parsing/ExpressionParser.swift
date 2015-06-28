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
            case Error(String)
            case WaitingForAnyExpression
            case LeadingDot
            case Identifier(identifierStart: String.Index)
            case CompoundIdentifier(identifierStart: String.Index, baseExpression: Expression)
            case WaitingForCompoundIdentifier(baseExpression: Expression)
            case IdentifierDone(expression: Expression)
            case FilterDone(expression: Expression)
            case Empty
            case Valid(expression: Expression)
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
                case "(":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case ")":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case ",":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                default:
                    state = .Identifier(identifierStart: i)
                }
                
            case .LeadingDot:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .IdentifierDone(expression: Expression.ImplicitIterator)
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case "(":
                    filterExpressionStack.append(Expression.ImplicitIterator)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: false)
                        state = .FilterDone(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                default:
                    state = .CompoundIdentifier(identifierStart: i, baseExpression: Expression.ImplicitIterator)
                }
                
            case .Identifier(identifierStart: let identifierStart):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    state = .IdentifierDone(expression: Expression.identifier(identifier))
                case ".":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    state = .WaitingForCompoundIdentifier(baseExpression: Expression.identifier(identifier))
                case "(":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    filterExpressionStack.append(Expression.identifier(identifier))
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let expression = Expression.filter(filterExpression: filterExpression, argumentExpression: Expression.identifier(identifier), partialApplication: false)
                        state = .FilterDone(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        filterExpressionStack.append(Expression.filter(filterExpression: filterExpression, argumentExpression: Expression.identifier(identifier), partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                default:
                    break
                }
                
            case .CompoundIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .IdentifierDone(expression: scopedExpression)
                case ".":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .WaitingForCompoundIdentifier(baseExpression: scopedExpression)
                case "(":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                    filterExpressionStack.append(scopedExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                        let expression = Expression.filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: false)
                        state = .FilterDone(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = string.substringWithRange(identifierStart..<i)
                        let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                        filterExpressionStack.append(Expression.filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                default:
                    break
                }
                
            case .WaitingForCompoundIdentifier(let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .Error("Unexpected white space character at index \(distance(string.startIndex, i))")
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case "(":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case ")":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case ",":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                default:
                    state = .CompoundIdentifier(identifierStart: i, baseExpression: baseExpression)
                }
                
            case .IdentifierDone(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                case "(":
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .FilterDone(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                default:
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                }
            case .FilterDone(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .WaitingForCompoundIdentifier(baseExpression: doneExpression)
                case "(":
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .FilterDone(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                    }
                default:
                    state = .Error("Unexpected character `\(c)` at index \(distance(string.startIndex, i))")
                }
            case .Empty, .Valid:
                fatalError("Unexpected state")
            }
            
            i = i.successor()
        }
        
        switch state {
        case .WaitingForAnyExpression:
            if filterExpressionStack.isEmpty {
                state = .Empty
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .LeadingDot:
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: Expression.ImplicitIterator)
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .Identifier(identifierStart: let identifierStart):
            if filterExpressionStack.isEmpty {
                let identifier = string.substringFromIndex(identifierStart)
                state = .Valid(expression: Expression.identifier(identifier))
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .CompoundIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
            if filterExpressionStack.isEmpty {
                let identifier = string.substringFromIndex(identifierStart)
                let scopedExpression = Expression.scoped(baseExpression: baseExpression, identifier: identifier)
                state = .Valid(expression: scopedExpression)
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .WaitingForCompoundIdentifier:
            state = .Error("Missing identifier at index \(distance(string.startIndex, string.endIndex))")
            
        case .IdentifierDone(let doneExpression):
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: doneExpression)
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .FilterDone(let doneExpression):
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: doneExpression)
            } else {
                state = .Error("Missing `)` character at index \(distance(string.startIndex, string.endIndex))")
            }
            
        case .Error:
            break
        default:
            fatalError("Unexpected state")
        }
        
        // End
        
        switch state {
        case .Empty:
            outEmpty = true
            throw NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Missing expression"])
        case .Error(let description):
            outEmpty = false
            throw NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Invalid expression `\(string)`: \(description)"])
        case .Valid(expression: let validExpression):
            return validExpression
        default:
            fatalError("Unexpected state")
        }
    }
}
