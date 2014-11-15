//
//  ExpressionParser.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

class ExpressionParser {
    
    func parse(string: String, inout empty outEmpty: Bool, error outError: NSErrorPointer) -> Expression? {
        
        enum State {
            case Error
            case Initial
            case LeadingDot
            case Identifier(start: String.Index)
            case WaitingForIdentifier
            case IdentifierDone
            case FilterDone
            case Empty
            case Valid(expression: Expression)
        }
        
        var state: State = .Initial
        var filterExpressionStack: [Expression] = []
        var currentExpression: Expression?
        
        var i = string.startIndex
        let end = string.endIndex
        stringLoop: while i < end {
            let c = string[i]
            
            switch state {
            case .Error:
                break stringLoop
            case .Initial:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .LeadingDot
                    currentExpression = ImplicitIteratorExpression()
                case "(":
                    state = .Error
                case ")":
                    state = .Error
                case ",":
                    state = .Error
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error
                default:
                    state = .Identifier(start: i)
                }
            case .LeadingDot:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .IdentifierDone
                case ".":
                    state = .Error
                case "(":
                    state = .Initial
                    filterExpressionStack.append(currentExpression!)
                    currentExpression = nil
                case ")":
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .FilterDone
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: false)
                    }
                case ",":
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .Initial
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: true)
                    }
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error
                default:
                    state = .Identifier(start: i)
                }
            case .Identifier(start: let identifierStart):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    if currentExpression != nil {
                        currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
                    } else {
                        currentExpression = IdentifierExpression(identifier: identifier)
                    }
                    state = .IdentifierDone
                case ".":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    if currentExpression != nil {
                        currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
                    } else {
                        currentExpression = IdentifierExpression(identifier: identifier)
                    }
                    state = .WaitingForIdentifier
                case "(":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    if currentExpression != nil {
                        currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
                    } else {
                        currentExpression = IdentifierExpression(identifier: identifier)
                    }
                    state = .Initial
                    filterExpressionStack.append(currentExpression!)
                    currentExpression = nil
                case ")":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    if currentExpression != nil {
                        currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
                    } else {
                        currentExpression = IdentifierExpression(identifier: identifier)
                    }
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .FilterDone
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: false)
                    }
                case ",":
                    let identifier = string.substringWithRange(identifierStart..<i)
                    if currentExpression != nil {
                        currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
                    } else {
                        currentExpression = IdentifierExpression(identifier: identifier)
                    }
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .Initial
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: true)
                    }
                default:
                    break
                }
            case .WaitingForIdentifier:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .Error
                case ".":
                    state = .Error
                case "(":
                    state = .Error
                case ")":
                    state = .Error
                case ",":
                    state = .Error
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error
                default:
                    state = .Identifier(start: i)
                }
            case .IdentifierDone:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .Error
                case "(":
                    state = .Initial
                    filterExpressionStack.append(currentExpression!)
                    currentExpression = nil
                case ")":
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .FilterDone
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: false)
                    }
                case ",":
                    if filterExpressionStack.isEmpty {
                        state = .Error
                    } else {
                        state = .Initial
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: true)
                    }
                default:
                    state = .Error
                }
            case .FilterDone:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .WaitingForIdentifier
                case "(":
                    state = .Initial
                    filterExpressionStack.append(currentExpression!)
                    currentExpression = nil
                case ")":
                    if filterExpressionStack.isEmpty {
                        state = .FilterDone
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        currentExpression = FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: false)
                    } else {
                        state = .Error
                    }
                case ",":
                    if filterExpressionStack.isEmpty {
                        state = .Initial
                        let filterExpression = filterExpressionStack[filterExpressionStack.endIndex - 1]
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(FilteredExpression(filterExpression: filterExpression, argumentExpression: currentExpression!, curried: true))
                        currentExpression = nil
                    } else {
                        state = .Error
                    }
                default:
                    state = .Error
                }
            default:
                fatalError("Unexpected state")
            }
            
            i = i.successor()
        }
        
        switch state {
        case .Initial:
            if filterExpressionStack.isEmpty {
                state = .Empty
            } else {
                state = .Error
            }
        case .LeadingDot:
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: currentExpression!)
            } else {
                state = .Error
            }
        case .Identifier(start: let identifierStart):
            let identifier = string.substringFromIndex(identifierStart)
            if currentExpression != nil {
                currentExpression = ScopedExpression(baseExpression:currentExpression!, identifier: identifier)
            } else {
                currentExpression = IdentifierExpression(identifier: identifier)
            }
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: currentExpression!)
            } else {
                state = .Error
            }
        case .WaitingForIdentifier:
            state = .Error
        case .IdentifierDone:
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: currentExpression!)
            } else {
                state = .Error
            }
        case .FilterDone:
            if filterExpressionStack.isEmpty {
                state = .Valid(expression: currentExpression!)
            } else {
                state = .Error
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
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Missing expression"])
            }
            return nil
        case .Error:
            outEmpty = false
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Invalid expression"])
            }
            return nil
        case .Valid(expression: let validExpression):
            return validExpression
        default:
            fatalError("Unexpected state")
        }
        
        return nil
    }
}
