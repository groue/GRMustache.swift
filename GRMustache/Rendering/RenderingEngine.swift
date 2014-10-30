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
            let value = expressionInvocation.value
            let renderingOptions = RenderingOptions(context: context, enumerationItem: false)
            var rendering: String
            var renderingContentType: ContentType
            switch tag.type {
            case .Variable:
                if let (r, c) = renderMustacheValue(value, tag: tag, options: renderingOptions, error: outError) {
                    (rendering, renderingContentType) = (r, c)
                } else {
                    return false
                }
            case .Section:
                let boolValue = value.mustacheBoolValue
                if boolValue {
                    if let (r, c) = renderMustacheValue(value, tag: tag, options: renderingOptions, error: outError) {
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
                    if let (r, c) = renderMustacheValue(value, tag: tag, options: renderingOptions, error: outError) {
                        (rendering, renderingContentType) = (r, c)
                    } else {
                        return false
                    }
                }
            }
            
            switch (contentType, renderingContentType, escapesHTML) {
            case (.HTML, .Text, true):
                buffer = buffer! + TranslateHTMLCharacters(rendering)
            default:
                buffer = buffer! + rendering
            }
            
            return true
        } else {
            return false
        }
    }


    func renderMustacheValue(value: MustacheValue, tag: Tag, options: RenderingOptions, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        switch value.type {
        case .None:
            switch tag.type {
            case .Variable:
                return (rendering: "", contentType: .Text)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .BoolValue(let bool):
            switch tag.type {
            case .Variable:
                return (rendering: "\(bool)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .IntValue(let int):
            switch tag.type {
            case .Variable:
                return (rendering: "\(int)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .DoubleValue(let double):
            switch tag.type {
            case .Variable:
                return (rendering: "\(double)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .StringValue(let string):
            switch tag.type {
            case .Variable:
                return (rendering:string, contentType:.Text)
                
            case .Section:
                // TODO: why isn't it the same rendering code as Number?
                return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
                
            case .InvertedSection:
                // TODO: why isn't it the same rendering code as Number?
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .DictionaryValue(let dictionary):
            switch tag.type {
            case .Variable:
                return (rendering:"\(dictionary)", contentType:.Text)
                
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
            }
        case .ArrayValue(let array):
            if options.enumerationItem {
                return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                for item in array {
                    empty = false
                    let itemOptions = RenderingOptions(context: options.context, enumerationItem: true)
                    if let (itemRendering, itemContentType) = renderMustacheValue(item, tag: tag, options: itemOptions, error: outError) {
                        if contentType == nil {
                            contentType = itemContentType
                            buffer = buffer + itemRendering
                        } else if contentType == itemContentType {
                            buffer = buffer + itemRendering
                        } else {
                            if outError != nil {
                                outError.memory = NSError(domain: "TODO", code: 0, userInfo: nil)
                            }
                            return nil
                        }
                    } else {
                        return nil
                    }
                }
                
                if empty {
                    switch tag.type {
                    case .Variable:
                        return (rendering: "", contentType: .Text)
                    case .Section, .InvertedSection:
                        return tag.renderContentWithContext(options.context, error: outError)
                    }
                } else {
                    return (rendering: buffer, contentType: contentType!)
                }
            }
        case .FilterValue(_):
            switch tag.type {
            case .Variable:
                return (rendering:"[Filter]", contentType:.Text)
                
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
                
            case .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .ObjCValue(let object):
            switch tag.type {
            case .Variable:
                return (rendering:"\(object)", contentType:.Text)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context.contextByAddingValue(value), error: outError)
            }
        case .CustomValue(let object):
            return object.renderForMustacheTag(tag, options: options, error: outError)
        }
    }
    
}