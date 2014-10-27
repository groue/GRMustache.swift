//
//  TemplateCompiler.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class TemplateCompiler: TemplateTokenConsumer {
    
    init(contentType: ContentType) {
        self.state = .templateAST(.Some(nodes: [], contentType: contentType))
    }
    
    func templateAST(error outError: NSErrorPointer) -> TemplateAST? {
        switch(state) {
        case .templateAST(let templateAST):
            return templateAST
        case .error(let error):
            if outError != nil {
                outError.memory = error
            }
            return nil
        }
    }
    
    
    // MARK: - TemplateTokenConsumer
    
    func parser(parser: TemplateParser, didFailWithError error: NSError) {
        state = .error(error)
    }
    
    func parser(parser: TemplateParser, shouldContinueAfterParsingToken token: TemplateToken) -> Bool {
        switch(state) {
        case .error:
            return false
        case .templateAST:
            break
        }
        
        switch(token.type) {
        case .SetDelimiters:
            break
            
        case .Comment:
            break
            
        case .Pragma(let content):
            break
            
        case .Text(let text):
            state.appendNode(TextNode(text: text))
            break
            
        case .EscapedVariable(let content):
            var error: NSError?
            var empty = false
            let expressionParser = ExpressionParser()
            if let expression = expressionParser.parse(content, empty: &empty, error: &error) {
                state.appendNode(VariableTag(expression: expression, contentType: .HTML, escapesHTML: true))
            }
            break
            
        case .UnescapedVariable(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .Section(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .InvertedSection(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .InheritableSection(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .InheritablePartial(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .Close(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
            
        case .Partial(let content):
            self.state = .error(NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: "Not implemented yet"]))
            return false
        }
        
        return true
    }
    
    
    // MARK: - Private
    
    enum CompilationState {
        case templateAST(TemplateAST)
        case error(NSError)
        
        mutating func appendNode(node: TemplateASTNode) {
            switch(self) {
            case .error:
                break
            case .templateAST(let templateAST):
                switch templateAST {
                case .None:
                    break
                case .Some(let nodes, let contentType):
                    self = .templateAST(.Some(nodes: nodes + [node], contentType: contentType))
                }
            }
        }
    }
    
    private var state: CompilationState
    
}
