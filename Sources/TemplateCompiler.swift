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

final class TemplateCompiler: TemplateTokenConsumer {
    private var state: CompilerState
    private let repository: TemplateRepository
    private let templateID: TemplateID?
    
    init(contentType: ContentType, repository: TemplateRepository, templateID: TemplateID?) {
        self.state = .Compiling(CompilationState(contentType: contentType))
        self.repository = repository
        self.templateID = templateID
    }
    
    func templateAST() throws -> TemplateAST {
        switch(state) {
        case .Compiling(let compilationState):
            switch compilationState.currentScope.type {
            case .Root:
                return TemplateAST(nodes: compilationState.currentScope.templateASTNodes, contentType: compilationState.contentType)
            case .Section(openingToken: let openingToken, expression: _):
                throw MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: openingToken.templateID, lineNumber: openingToken.lineNumber)
            case .InvertedSection(openingToken: let openingToken, expression: _):
                throw MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: openingToken.templateID, lineNumber: openingToken.lineNumber)
            case .PartialOverride(openingToken: let openingToken, parentPartialName: _):
                throw MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: openingToken.templateID, lineNumber: openingToken.lineNumber)
            case .Block(openingToken: let openingToken, blockName: _):
                throw MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: openingToken.templateID, lineNumber: openingToken.lineNumber)
            }
        case .Error(let compilationError):
            throw compilationError
        }
    }
    
    
    // MARK: - TemplateTokenConsumer
    
    func parser(parser: TemplateParser, didFailWithError error: ErrorType) {
        state = .Error(error)
    }
    
    func parser(parser: TemplateParser, shouldContinueAfterParsingToken token: TemplateToken) -> Bool {
        switch(state) {
        case .Error:
            return false
        case .Compiling(let compilationState):
            do {
                switch(token.type) {
                    
                case .SetDelimiters:
                    // noop
                    break
                    
                case .Comment:
                    // noop
                    break
                    
                case .Pragma(content: let content):
                    let pragma = content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if (try! NSRegularExpression(pattern: "^CONTENT_TYPE\\s*:\\s*TEXT$", options: NSRegularExpressionOptions(rawValue: 0))).firstMatchInString(pragma, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, (pragma as NSString).length)) != nil {
                        switch compilationState.compilerContentType {
                        case .Unlocked:
                            compilationState.compilerContentType = .Unlocked(.Text)
                        case .Locked(_):
                            throw MustacheError(kind: .ParseError, message:"CONTENT_TYPE:TEXT pragma tag must prepend any Mustache variable, section, or partial tag.", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                    } else if (try! NSRegularExpression(pattern: "^CONTENT_TYPE\\s*:\\s*HTML$", options: NSRegularExpressionOptions(rawValue: 0))).firstMatchInString(pragma, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, (pragma as NSString).length)) != nil {
                        switch compilationState.compilerContentType {
                        case .Unlocked:
                            compilationState.compilerContentType = .Unlocked(.HTML)
                        case .Locked(_):
                            throw MustacheError(kind: .ParseError, message:"CONTENT_TYPE:HTML pragma tag must prepend any Mustache variable, section, or partial tag.", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                    }
                    
                case .Text(text: let text):
                    switch compilationState.currentScope.type {
                    case .PartialOverride:
                        // Text inside a partial override tag is not rendered.
                        //
                        // We could throw an error, like we do for illegal tags
                        // inside a partial override tag.
                        //
                        // But Hogan.js has an explicit test for "successfully"
                        // ignored text. So let's not throw.
                        //
                        // Ignore text inside a partial override tag:
                        break
                    default:
                        compilationState.currentScope.appendNode(TemplateASTNode.text(text: text))
                    }
                    
                case .EscapedVariable(content: let content, tagDelimiterPair: _):
                    switch compilationState.currentScope.type {
                    case .PartialOverride:
                        throw MustacheError(kind: .ParseError, message:"Illegal tag inside a partial override tag.", templateID: token.templateID, lineNumber: token.lineNumber)
                    default:
                        var empty = false
                        do {
                            let expression = try ExpressionParser().parse(content, empty: &empty)
                            compilationState.currentScope.appendNode(TemplateASTNode.variable(expression: expression, contentType: compilationState.contentType, escapesHTML: true, token: token))
                            compilationState.compilerContentType = .Locked(compilationState.contentType)
                        } catch let error as MustacheError {
                            throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                    }
                    
                case .UnescapedVariable(content: let content, tagDelimiterPair: _):
                    switch compilationState.currentScope.type {
                    case .PartialOverride:
                        throw MustacheError(kind: .ParseError, message: "Illegal tag inside a partial override tag: \(token.templateSubstring)", templateID: token.templateID, lineNumber: token.lineNumber)
                    default:
                        var empty = false
                        do {
                            let expression = try ExpressionParser().parse(content, empty: &empty)
                            compilationState.currentScope.appendNode(TemplateASTNode.variable(expression: expression, contentType: compilationState.contentType, escapesHTML: false, token: token))
                            compilationState.compilerContentType = .Locked(compilationState.contentType)
                        } catch let error as MustacheError {
                            throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                    }
                    
                case .Section(content: let content, tagDelimiterPair: _):
                    switch compilationState.currentScope.type {
                    case .PartialOverride:
                        throw MustacheError(kind: .ParseError, message: "Illegal tag inside a partial override tag: \(token.templateSubstring)", templateID: token.templateID, lineNumber: token.lineNumber)
                    default:
                        var empty = false
                        do {
                            let expression = try ExpressionParser().parse(content, empty: &empty)
                            compilationState.pushScope(Scope(type: .Section(openingToken: token, expression: expression)))
                            compilationState.compilerContentType = .Locked(compilationState.contentType)
                        } catch let error as MustacheError {
                            throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                    }
                    
                case .InvertedSection(content: let content, tagDelimiterPair: _):
                    switch compilationState.currentScope.type {
                    case .PartialOverride:
                        throw MustacheError(kind: .ParseError, message: "Illegal tag inside a partial override tag: \(token.templateSubstring)", templateID: token.templateID, lineNumber: token.lineNumber)
                    default:
                        var empty = false
                        do {
                            let expression = try ExpressionParser().parse(content, empty: &empty)
                            compilationState.pushScope(Scope(type: .InvertedSection(openingToken: token, expression: expression)))
                            compilationState.compilerContentType = .Locked(compilationState.contentType)
                        } catch let error as MustacheError {
                            throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                    }
                    
                case .Block(content: let content):
                    var empty: Bool = false
                    let blockName = try blockNameFromString(content, inToken: token, empty: &empty)
                    compilationState.pushScope(Scope(type: .Block(openingToken: token, blockName: blockName)))
                    compilationState.compilerContentType = .Locked(compilationState.contentType)
                    
                case .PartialOverride(content: let content):
                    var empty: Bool = false
                    let parentPartialName = try partialNameFromString(content, inToken: token, empty: &empty)
                    compilationState.pushScope(Scope(type: .PartialOverride(openingToken: token, parentPartialName: parentPartialName)))
                    compilationState.compilerContentType = .Locked(compilationState.contentType)
                    
                case .Close(content: let content):
                    switch compilationState.currentScope.type {
                    case .Root:
                        throw MustacheError(kind: .ParseError, message: "Unmatched closing tag", templateID: token.templateID, lineNumber: token.lineNumber)
                        
                    case .Section(openingToken: let openingToken, expression: let closedExpression):
                        var empty: Bool = false
                        var expression: Expression?
                        do {
                            expression = try ExpressionParser().parse(content, empty: &empty)
                        } catch let error as MustacheError {
                            if empty == false {
                                throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                            }
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                        if expression != nil && expression != closedExpression {
                            throw MustacheError(kind: .ParseError, message: "Unmatched closing tag", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)

//                        // TODO: uncomment and make it compile
//                        if token.templateString !== openingToken.templateString {
//                            fatalError("Not implemented")
//                        }
                        let templateString = token.templateString
                        let innerContentRange = openingToken.range.endIndex..<token.range.startIndex
                        let sectionTag = TemplateASTNode.section(templateAST: templateAST, expression: closedExpression, inverted: false, openingToken: openingToken, innerTemplateString: templateString[innerContentRange])

                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(sectionTag)
                        
                    case .InvertedSection(openingToken: let openingToken, expression: let closedExpression):
                        var empty: Bool = false
                        var expression: Expression?
                        do {
                            expression = try ExpressionParser().parse(content, empty: &empty)
                        } catch let error as MustacheError {
                            if empty == false {
                                throw error.errorWith(templateID: token.templateID, lineNumber: token.lineNumber)
                            }
                        } catch {
                            throw MustacheError(kind: .ParseError, templateID: token.templateID, lineNumber: token.lineNumber, underlyingError: error)
                        }
                        if expression != nil && expression != closedExpression {
                            throw MustacheError(kind: .ParseError, message: "Unmatched closing tag", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)
                        
//                        // TODO: uncomment and make it compile
//                        if token.templateString !== openingToken.templateString {
//                            fatalError("Not implemented")
//                        }
                        let templateString = token.templateString
                        let innerContentRange = openingToken.range.endIndex..<token.range.startIndex
                        let sectionTag = TemplateASTNode.section(templateAST: templateAST, expression: closedExpression, inverted: true, openingToken: openingToken, innerTemplateString: templateString[innerContentRange])
                        
                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(sectionTag)
                        
                    case .PartialOverride(openingToken: _, parentPartialName: let parentPartialName):
                        var empty: Bool = false
                        var partialName: String?
                        do {
                            partialName = try partialNameFromString(content, inToken: token, empty: &empty)
                        } catch {
                            if empty == false {
                                throw error
                            }
                        }
                        if partialName != nil && partialName != parentPartialName {
                            throw MustacheError(kind: .ParseError, message: "Unmatched closing tag", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                        
                        let parentTemplateAST = try repository.templateAST(named: parentPartialName, relativeToTemplateID:templateID)
                        switch parentTemplateAST.type {
                        case .Undefined:
                            break
                        case .Defined(nodes: _, contentType: let partialContentType):
                            if partialContentType != compilationState.contentType {
                                throw MustacheError(kind: .ParseError, message: "Content type mismatch", templateID: token.templateID, lineNumber: token.lineNumber)
                            }
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)
                        let partialOverrideNode = TemplateASTNode.partialOverride(childTemplateAST: templateAST, parentTemplateAST: parentTemplateAST, parentPartialName: parentPartialName)
                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(partialOverrideNode)
                        
                    case .Block(openingToken: _, blockName: let closedBlockName):
                        var empty: Bool = false
                        var blockName: String?
                        do {
                            blockName = try blockNameFromString(content, inToken: token, empty: &empty)
                        } catch {
                            if empty == false {
                                throw error
                            }
                        }
                        if blockName != nil && blockName != closedBlockName {
                            throw MustacheError(kind: .ParseError, message: "Unmatched closing tag", templateID: token.templateID, lineNumber: token.lineNumber)
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)
                        let blockNode = TemplateASTNode.block(innerTemplateAST: templateAST, name: closedBlockName)
                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(blockNode)
                    }
                    
                case .Partial(content: let content):
                    var empty: Bool = false
                    let partialName = try partialNameFromString(content, inToken: token, empty: &empty)
                    let partialTemplateAST = try repository.templateAST(named: partialName, relativeToTemplateID: templateID)
                    let partialNode = TemplateASTNode.partial(templateAST: partialTemplateAST, name: partialName)
                    compilationState.currentScope.appendNode(partialNode)
                    compilationState.compilerContentType = .Locked(compilationState.contentType)
                }
                
                return true
            } catch {
                state = .Error(error)
                return false
            }
        }
    }
    
    
    // MARK: - Private
    
    private class CompilationState {
        var currentScope: Scope {
            return scopeStack[scopeStack.endIndex - 1]
        }
        var contentType: ContentType {
            switch compilerContentType {
            case .Unlocked(let contentType):
                return contentType
            case .Locked(let contentType):
                return contentType
            }
        }
        
        init(contentType: ContentType) {
            self.compilerContentType = .Unlocked(contentType)
            self.scopeStack = [Scope(type: .Root)]
        }
        
        func popCurrentScope() {
            scopeStack.removeLast()
        }
        
        func pushScope(scope: Scope) {
            scopeStack.append(scope)
        }
        
        enum CompilerContentType {
            case Unlocked(ContentType)
            case Locked(ContentType)
        }
        
        var compilerContentType: CompilerContentType
        private var scopeStack: [Scope]
    }
    
    private enum CompilerState {
        case Compiling(CompilationState)
        case Error(ErrorType)
    }
    
    private class Scope {
        let type: Type
        var templateASTNodes: [TemplateASTNode]
        
        init(type:Type) {
            self.type = type
            self.templateASTNodes = []
        }
        
        func appendNode(node: TemplateASTNode) {
            templateASTNodes.append(node)
        }
        
        enum `Type` {
            case Root
            case Section(openingToken: TemplateToken, expression: Expression)
            case InvertedSection(openingToken: TemplateToken, expression: Expression)
            case PartialOverride(openingToken: TemplateToken, parentPartialName: String)
            case Block(openingToken: TemplateToken, blockName: String)
        }
    }
    
    private func blockNameFromString(string: String, inToken token: TemplateToken, inout empty: Bool) throws -> String {
        let whiteSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let blockName = string.stringByTrimmingCharactersInSet(whiteSpace)
        if blockName.characters.count == 0 {
            empty = true
            throw MustacheError(kind: .ParseError, message: "Missing block name", templateID: token.templateID, lineNumber: token.lineNumber)
        } else if (blockName.rangeOfCharacterFromSet(whiteSpace) != nil) {
            empty = false
            throw MustacheError(kind: .ParseError, message: "Invalid block name", templateID: token.templateID, lineNumber: token.lineNumber)
        }
        return blockName
    }
    
    private func partialNameFromString(string: String, inToken token: TemplateToken, inout empty: Bool) throws -> String {
        let whiteSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let partialName = string.stringByTrimmingCharactersInSet(whiteSpace)
        if partialName.characters.count == 0 {
            empty = true
            throw MustacheError(kind: .ParseError, message: "Missing template name", templateID: token.templateID, lineNumber: token.lineNumber)
        } else if (partialName.rangeOfCharacterFromSet(whiteSpace) != nil) {
            empty = false
            throw MustacheError(kind: .ParseError, message: "Invalid template name", templateID: token.templateID, lineNumber: token.lineNumber)
        }
        return partialName
    }
}
