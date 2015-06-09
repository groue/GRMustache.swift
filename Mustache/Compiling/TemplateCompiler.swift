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
                throw parseErrorAtToken(openingToken, description: "Unclosed Mustache tag")
            case .InvertedSection(openingToken: let openingToken, expression: _):
                throw parseErrorAtToken(openingToken, description: "Unclosed Mustache tag")
            case .InheritedPartial(openingToken: let openingToken, partialName: _):
                throw parseErrorAtToken(openingToken, description: "Unclosed Mustache tag")
            case .InheritableSection(openingToken: let openingToken, inheritableSectionName: _):
                throw parseErrorAtToken(openingToken, description: "Unclosed Mustache tag")
            }
        case .Error(let compilationError):
            throw compilationError
        }
    }
    
    
    // MARK: - TemplateTokenConsumer
    
    func parser(parser: TemplateParser, didFailWithError error: NSError) {
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
                            throw parseErrorAtToken(token, description: "CONTENT_TYPE:TEXT pragma tag must prepend any Mustache variable, section, or partial tag.")
                        }
                    } else if (try! NSRegularExpression(pattern: "^CONTENT_TYPE\\s*:\\s*HTML$", options: NSRegularExpressionOptions(rawValue: 0))).firstMatchInString(pragma, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, (pragma as NSString).length)) != nil {
                        switch compilationState.compilerContentType {
                        case .Unlocked:
                            compilationState.compilerContentType = .Unlocked(.HTML)
                        case .Locked(_):
                            throw parseErrorAtToken(token, description: "CONTENT_TYPE:HTML pragma tag must prepend any Mustache variable, section, or partial tag.")
                        }
                    }
                    
                case .Text(text: let text):
                    compilationState.currentScope.appendNode(TemplateASTNode.text(text: text))
                    
                case .EscapedVariable(content: let content, tagDelimiterPair: _):
                    var empty = false
                    do {
                        let expression = try ExpressionParser().parse(content, empty: &empty)
                        compilationState.currentScope.appendNode(TemplateASTNode.variable(expression: expression, contentType: compilationState.contentType, escapesHTML: true, token: token))
                        compilationState.compilerContentType = .Locked(compilationState.contentType)
                    } catch let error as NSError {
                        throw parseErrorAtToken(token, description: error.localizedDescription)
                    }
                    
                case .UnescapedVariable(content: let content, tagDelimiterPair: _):
                    var empty = false
                    do {
                        let expression = try ExpressionParser().parse(content, empty: &empty)
                        compilationState.currentScope.appendNode(TemplateASTNode.variable(expression: expression, contentType: compilationState.contentType, escapesHTML: false, token: token))
                        compilationState.compilerContentType = .Locked(compilationState.contentType)
                    } catch let error as NSError {
                        throw parseErrorAtToken(token, description: error.localizedDescription)
                    }
                    
                case .Section(content: let content, tagDelimiterPair: _):
                    var empty = false
                    do {
                        let expression = try ExpressionParser().parse(content, empty: &empty)
                        compilationState.pushScope(Scope(type: .Section(openingToken: token, expression: expression)))
                        compilationState.compilerContentType = .Locked(compilationState.contentType)
                    } catch let error as NSError {
                        throw parseErrorAtToken(token, description: error.localizedDescription)
                    }
                    
                case .InvertedSection(content: let content, tagDelimiterPair: _):
                    var empty = false
                    do {
                        let expression = try ExpressionParser().parse(content, empty: &empty)
                        compilationState.pushScope(Scope(type: .InvertedSection(openingToken: token, expression: expression)))
                        compilationState.compilerContentType = .Locked(compilationState.contentType)
                    } catch let error as NSError {
                        throw parseErrorAtToken(token, description: error.localizedDescription)
                    }
                    
                case .InheritableSection(content: let content):
                    var empty: Bool = false
                    let inheritableSectionName = try inheritableSectionNameFromString(content, inToken: token, empty: &empty)
                    compilationState.pushScope(Scope(type: .InheritableSection(openingToken: token, inheritableSectionName: inheritableSectionName)))
                    compilationState.compilerContentType = .Locked(compilationState.contentType)
                    
                case .InheritedPartial(content: let content):
                    var empty: Bool = false
                    let partialName = try partialNameFromString(content, inToken: token, empty: &empty)
                    compilationState.pushScope(Scope(type: .InheritedPartial(openingToken: token, partialName: partialName)))
                    compilationState.compilerContentType = .Locked(compilationState.contentType)
                    
                case .Close(content: let content):
                    switch compilationState.currentScope.type {
                    case .Root:
                        throw parseErrorAtToken(token, description: "Unmatched closing tag")
                        
                    case .Section(openingToken: let openingToken, expression: let closedExpression):
                        var empty: Bool = false
                        var expression: Expression?
                        do {
                            expression = try ExpressionParser().parse(content, empty: &empty)
                        } catch let error as NSError {
                            if empty == false {
                                throw parseErrorAtToken(token, description: error.localizedDescription)
                            }
                        }
                        if expression != closedExpression {
                            throw parseErrorAtToken(token, description: "Unmatched closing tag")
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
                        } catch let error as NSError {
                            if empty == false {
                                throw parseErrorAtToken(token, description: error.localizedDescription)
                            }
                        }
                        if expression != closedExpression {
                            throw parseErrorAtToken(token, description: "Unmatched closing tag")
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
                        
                    case .InheritedPartial(openingToken: _, partialName: let inheritedPartialName):
                        var empty: Bool = false
                        var partialName: String?
                        do {
                            partialName = try partialNameFromString(content, inToken: token, empty: &empty)
                        } catch let error as NSError {
                            if empty == false {
                                throw error
                            }
                        }
                        if (partialName != inheritedPartialName) {
                            throw parseErrorAtToken(token, description: "Unmatched closing tag")
                        }
                        
                        let inheritedTemplateAST = try repository.templateAST(named: inheritedPartialName, relativeToTemplateID:templateID)
                        switch inheritedTemplateAST.type {
                        case .Undefined:
                            break
                        case .Defined(nodes: _, contentType: let partialContentType):
                            if partialContentType != compilationState.contentType {
                                throw parseErrorAtToken(token, description: "Content type mismatch")
                            }
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)
                        let inheritedPartialNode = TemplateASTNode.inheritedPartial(overridingTemplateAST: templateAST, inheritedTemplateAST: inheritedTemplateAST, inheritedPartialName: inheritedPartialName)
                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(inheritedPartialNode)
                        
                    case .InheritableSection(openingToken: _, inheritableSectionName: let closedInheritableSectionName):
                        var empty: Bool = false
                        var inheritableSectionName: String?
                        do {
                            inheritableSectionName = try inheritableSectionNameFromString(content, inToken: token, empty: &empty)
                        } catch let error as NSError {
                            if empty == false {
                                throw parseErrorAtToken(token, description: error.localizedDescription)
                            }
                        }
                        if inheritableSectionName != closedInheritableSectionName {
                            throw parseErrorAtToken(token, description: "Unmatched closing tag")
                        }
                        
                        let templateASTNodes = compilationState.currentScope.templateASTNodes
                        let templateAST = TemplateAST(nodes: templateASTNodes, contentType: compilationState.contentType)
                        let inheritableSectionTag = TemplateASTNode.inheritableSection(innerTemplateAST: templateAST, name: closedInheritableSectionName)
                        compilationState.popCurrentScope()
                        compilationState.currentScope.appendNode(inheritableSectionTag)
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
            } catch let error as NSError {
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
        case Error(NSError)
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
        
        enum Type {
            case Root
            case Section(openingToken: TemplateToken, expression: Expression)
            case InvertedSection(openingToken: TemplateToken, expression: Expression)
            case InheritedPartial(openingToken: TemplateToken, partialName: String)
            case InheritableSection(openingToken: TemplateToken, inheritableSectionName: String)
        }
    }
    
    private func inheritableSectionNameFromString(string: String, inToken token: TemplateToken, inout empty: Bool) throws -> String {
        let whiteSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let inheritableSectionName = string.stringByTrimmingCharactersInSet(whiteSpace)
        if inheritableSectionName.characters.count == 0 {
            empty = true
            throw parseErrorAtToken(token, description: "Missing inheritable section name")
        } else if (inheritableSectionName.rangeOfCharacterFromSet(whiteSpace) != nil) {
            empty = false
            throw parseErrorAtToken(token, description: "Invalid inheritable section name")
        }
        return inheritableSectionName
    }
    
    private func partialNameFromString(string: String, inToken token: TemplateToken, inout empty: Bool) throws -> String {
        let whiteSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let partialName = string.stringByTrimmingCharactersInSet(whiteSpace)
        if partialName.characters.count == 0 {
            empty = true
            throw parseErrorAtToken(token, description: "Missing template name")
        } else if (partialName.rangeOfCharacterFromSet(whiteSpace) != nil) {
            empty = false
            throw parseErrorAtToken(token, description: "Invalid template name")
        }
        return partialName
    }
    
    private func parseErrorAtToken(token: TemplateToken, description: String) -> NSError {
        var localizedDescription: String
        if let templateID = templateID {
            localizedDescription = "Parse error at line \(token.lineNumber) of template \(templateID): \(description)"
        } else {
            localizedDescription = "Parse error at line \(token.lineNumber): \(description)"
        }
        return NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
    }
}
