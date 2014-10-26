//
//  RenderingEngine.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class RenderingEngine: TemplateASTVisitor {
    let contentType: ContentType
    let context: Context
    var buffer: String?
    
    init(contentType: ContentType, context: Context) {
        self.contentType = contentType
        self.context = context
    }
    
    func renderTemplateAST(templateAST: TemplateAST, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        buffer = ""
        if !visit(templateAST, error: outError) {
            return nil
        }
        return (rendering: buffer!, contentType: contentType)
    }
    
    
    // MARK: - TemplateASTVisitor
    
    func visit(templateAST: TemplateAST, error outError: NSErrorPointer) -> Bool {
        let ASTContentType = templateAST.contentType
        
        if contentType == ASTContentType {
            return visit(templateAST.nodes, error: outError)
        } else {
            // Render separately
            let renderingEngine = RenderingEngine(contentType: ASTContentType, context: context)
            if let (rendering, renderingContentType) = renderingEngine.renderTemplateAST(templateAST, error: outError) {
                if contentType == .HTML && renderingContentType == .Text {
                    buffer = buffer! + TranslateHTMLCharacters(rendering)
                } else {
                    buffer = buffer! + rendering
                }
                return true
            } else {
                return false
            }
        }
    }
    
    func visit(inheritablePartialNode: InheritablePartialNode, error outError: NSErrorPointer) -> Bool {
        return true
    }
    
    func visit(inheritableSectionNode: InheritableSectionNode, error outError: NSErrorPointer) -> Bool {
        return true
    }
    
    func visit(partialNode: PartialNode, error outError: NSErrorPointer) -> Bool {
        return true
    }
    
    func visit(variableTag: VariableTag, error outError: NSErrorPointer) -> Bool {
        return visit(variableTag, escapesHTML:variableTag.escapesHTML, error: outError)
    }
    
    func visit(sectionTag: SectionTag, error outError: NSErrorPointer) -> Bool {
        return visit(sectionTag, escapesHTML:true, error: outError)
    }
    
    func visit(textNode: TextNode, error outError: NSErrorPointer) -> Bool {
        buffer = buffer! + textNode.text
        return true
    }
    
    
    // MARK: - Private
    
    func visit(nodes: [TemplateASTNode], error outError: NSErrorPointer) -> Bool {
        for node in nodes {
            let node = context.resolveTemplateASTNode(node)
            if !node.acceptTemplateASTVisitor(self, error: outError) {
                return false
            }
        }
        return true
    }
    
    func visit(tag: Tag, escapesHTML: Bool, error outError: NSErrorPointer) -> Bool {
        
        // Evaluate expression
        
        let expressionInvocation = ExpressionInvocation(expression: tag.expression)
        if expressionInvocation.invokeWithContext(context, error: outError) {
            let value = expressionInvocation.value
            let renderingOptions = RenderingOptions(context: context, enumerationItem: false)
            var rendering: String
            var renderingContentType: ContentType
            switch tag.type {
            case .Variable:
                if let (r, c) = value.renderMustacheTag(tag, options: renderingOptions, error: outError) {
                    (rendering, renderingContentType) = (r, c)
                } else {
                    return false
                }
            case .Section:
                let boolValue = value.mustacheBoolValue
                if boolValue {
                    if let (r, c) = value.renderMustacheTag(tag, options: renderingOptions, error: outError) {
                        (rendering, renderingContentType) = (r, c)
                    } else {
                        return false
                    }
                } else {
                    rendering = ""
                    renderingContentType = .HTML
                }
            case .InvertedSection:
                let boolValue = value.mustacheBoolValue
                if boolValue {
                    rendering = ""
                    renderingContentType = .HTML
                } else {
                    if let (r, c) = value.renderMustacheTag(tag, options: renderingOptions, error: outError) {
                        (rendering, renderingContentType) = (r, c)
                    } else {
                        return false
                    }
                }
            }
            
            switch (contentType, renderingContentType) {
            case (.HTML, .Text):
                buffer = buffer! + TranslateHTMLCharacters(rendering)
            default:
                buffer = buffer! + rendering
            }
            
            return true
        } else {
            return false
        }
    }
}