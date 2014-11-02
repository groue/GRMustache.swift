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
    var context: Context
    var buffer: String?
    
    init(contentType: ContentType, context: Context) {
        self.contentType = contentType
        self.context = context
    }
    
    func renderTemplateAST(templateAST: TemplateAST, error outError: NSErrorPointer) -> MustacheRendering? {
        buffer = ""
        if !visit(templateAST, error: outError) {
            return nil
        }
        return MustacheRendering(string: buffer!, contentType: contentType)
    }
    
    
    // MARK: - TemplateASTVisitor
    
    func visit(templateAST: TemplateAST, error outError: NSErrorPointer) -> Bool {
        let ASTContentType = templateAST.contentType
        
        if contentType == ASTContentType {
            return visit(templateAST.nodes, error: outError)
        } else {
            // Render separately
            let renderingEngine = RenderingEngine(contentType: ASTContentType, context: context)
            if let rendering = renderingEngine.renderTemplateAST(templateAST, error: outError) {
                if contentType == .HTML && rendering.contentType == .Text {
                    buffer = buffer! + escapeHTML(rendering.string)
                } else {
                    buffer = buffer! + rendering.string
                }
                return true
            } else {
                return false
            }
        }
    }
    
    func visit(inheritablePartialNode: InheritablePartialNode, error outError: NSErrorPointer) -> Bool {
        let originalContext = context
        context = context.contextByAddingInheritablePartialNode(inheritablePartialNode)
        let success = visit(inheritablePartialNode.partialNode, error: outError)
        context = originalContext
        return success
    }
    
    func visit(inheritableSectionNode: InheritableSectionNode, error outError: NSErrorPointer) -> Bool {
        return visit(inheritableSectionNode.templateAST, error: outError)
    }
    
    func visit(partialNode: PartialNode, error outError: NSErrorPointer) -> Bool {
        return visit(partialNode.templateAST, error: outError)
    }
    
    func visit(variableTag: VariableTag, error outError: NSErrorPointer) -> Bool {
        return visit(variableTag, escapesHTML: variableTag.escapesHTML, error: outError)
    }
    
    func visit(sectionTag: SectionTag, error outError: NSErrorPointer) -> Bool {
        return visit(sectionTag, escapesHTML: true, error: outError)
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
            var value = expressionInvocation.value
            
            let tagObserverStack = context.tagObserverStack
            for tagObserver in tagObserverStack {
                value = tagObserver.mustacheTag(tag, willRenderValue: value)
            }
            
            let renderingOptions = RenderingOptions(enumerationItem: false)
            var rendering: MustacheRendering?
            var renderingError: NSError?
            switch tag.type {
            case .Variable:
                rendering = value.renderForMustacheTag(tag, context: context, options: renderingOptions, error: &renderingError)
            case .Section:
                let boolValue = value.mustacheBoolValue
                if boolValue {
                    rendering = value.renderForMustacheTag(tag, context: context, options: renderingOptions, error: &renderingError)
                } else {
                    rendering = MustacheRendering(string: "", contentType: .HTML)
                }
            case .InvertedSection:
                let boolValue = value.mustacheBoolValue
                if boolValue {
                    rendering = MustacheRendering(string: "", contentType: .HTML)
                } else {
                    rendering = value.renderForMustacheTag(tag, context: context, options: renderingOptions, error: &renderingError)
                }
            }
            
            for tagObserver in tagObserverStack.reverse() {
                tagObserver.mustacheTag(tag, didRender:rendering, forValue: value)
            }
            
            if let rendering = rendering {
                switch (contentType, rendering.contentType, escapesHTML) {
                case (.HTML, .Text, true):
                    buffer = buffer! + escapeHTML(rendering.string)
                default:
                    buffer = buffer! + rendering.string
                }
                return true
            } else {
                if outError != nil {
                    outError.memory = renderingError!
                }
                return false
            }
        } else {
            return false
        }
    }
}