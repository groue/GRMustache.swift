//
//  RenderingEngine.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public struct RenderingInfo {
    public let context: Context
    let enumerationItem: Bool
    
    public func renderingInfoByExtendingContextWithValue(value: Value) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingValue(value), enumerationItem: enumerationItem)
    }
    
    public func renderingInfoByExtendingContextWithTagObserver(tagObserver: MustacheTagObserver) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingTagObserver(tagObserver), enumerationItem: enumerationItem)
    }
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(context: context, enumerationItem: true)
    }
}

class RenderingEngine: TemplateASTVisitor {
    let contentType: ContentType
    var context: Context
    var buffer: String?
    
    init(contentType: ContentType, context: Context) {
        self.contentType = contentType
        self.context = context
    }
    
    func render(templateAST: TemplateAST, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        buffer = ""
        if !visit(templateAST, error: outError) {
            return nil
        }
        if outContentType != nil {
            outContentType.memory = contentType
        }
        return buffer!
    }
    
    
    // MARK: - Current Template Repository
    
    // Classes do not support (yet) stored properties.
    // Workaround is to use a wrapper struct.
    private struct TemplateRepositoryStack {
        // TODO: make it thread-safe
        static var stack: [TemplateRepository] = []
        static func append(repository: TemplateRepository) {
            stack.append(repository)
        }
        static func removeLast() {
            stack.removeLast()
        }
        static func lastObject() -> TemplateRepository? {
            if stack.isEmpty {
                return nil
            } else {
                return stack[stack.endIndex.predecessor()]
            }
        }
    }
    
    class func currentTemplateRepository() -> TemplateRepository? {
        return TemplateRepositoryStack.lastObject()
    }

    class func pushCurrentTemplateRepository(repository: TemplateRepository) {
        TemplateRepositoryStack.append(repository)
    }
    
    class func popCurrentTemplateRepository() {
        TemplateRepositoryStack.removeLast()
    }
    
    
    
    
    // MARK: - Current Content Type
    
    // Classes do not support (yet) stored properties.
    // Workaround is to use a wrapper struct.
    private struct ContentTypeStack {
        // TODO: make it thread-safe
        static var stack: [ContentType] = []
        static func append(repository: ContentType) {
            stack.append(repository)
        }
        static func removeLast() {
            stack.removeLast()
        }
        static func lastObject() -> ContentType? {
            if stack.isEmpty {
                return nil
            } else {
                return stack[stack.endIndex.predecessor()]
            }
        }
    }
    
    class func currentContentType() -> ContentType {
        if let contentType = ContentTypeStack.lastObject() {
            return contentType
        } else if let repository = currentTemplateRepository() {
            return repository.configuration.contentType
        } else {
            return Configuration.defaultConfiguration.contentType
        }
    }
    
    class func pushCurrentContentType(contentType: ContentType) {
        ContentTypeStack.append(contentType)
    }
    
    class func popCurrentContentType() {
        ContentTypeStack.removeLast()
    }
    
    
    // MARK: - TemplateASTVisitor
    
    func visit(templateAST: TemplateAST, error outError: NSErrorPointer) -> Bool {
        let ASTContentType = templateAST.contentType
        
        if contentType == ASTContentType {
            RenderingEngine.pushCurrentContentType(ASTContentType)
            let result = visit(templateAST.nodes, error: outError)
            RenderingEngine.popCurrentContentType()
            return result
        } else {
            // Render separately
            let renderingEngine = RenderingEngine(contentType: ASTContentType, context: context)
            var renderingContentType: ContentType = .Text
            if let rendering = renderingEngine.render(templateAST, contentType: &renderingContentType, error: outError) {
                switch (contentType, renderingContentType) {
                case (.HTML, .Text):
                    buffer = buffer! + escapeHTML(rendering)
                default:
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
    
    private func visit(nodes: [TemplateASTNode], error outError: NSErrorPointer) -> Bool {
        for node in nodes {
            let node = context.resolveTemplateASTNode(node)
            if !node.acceptTemplateASTVisitor(self, error: outError) {
                return false
            }
        }
        return true
    }
    
    private func visit(tag: MustacheExpressionTag, escapesHTML: Bool, error outError: NSErrorPointer) -> Bool {
        
        // Evaluate expression
        
        let expressionInvocation = ExpressionInvocation(expression: tag.expression)
        if expressionInvocation.invokeWithContext(context, error: outError) {
            var value = expressionInvocation.value
            
            let tagObserverStack = context.tagObserverStack
            for tagObserver in tagObserverStack {
                value = tagObserver.mustacheTag(tag, willRenderValue: value)
            }
            
            let renderingInfo = RenderingInfo(context: context, enumerationItem: false)
            var rendering: String?
            var renderingContentType: ContentType = .Text   // Default .Text, so that we assume unsafe rendering from users who do not explicitly set it.
            var renderingError: NSError? = nil              // Default nil, so that we assume success from users who do not explicitly set it.
            switch tag.type {
            case .Variable:
                rendering = value.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: &renderingContentType, error: &renderingError)
            case .Section:
                let boolValue = value.mustacheBool
                if tag.inverted {
                    if boolValue {
                        rendering = ""
                        renderingContentType = .Text
                    } else {
                        rendering = tag.renderContent(renderingInfo, contentType: &renderingContentType, error: &renderingError)
                    }
                } else {
                    if boolValue {
                        rendering = value.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: &renderingContentType, error: &renderingError)
                    } else {
                        rendering = ""
                        renderingContentType = .Text
                    }
                }
            }
            
            if rendering == nil && renderingError == nil {
                // Rendering is nil, but rendering error is not set.
                // Assume a rendering object coded by a lazy programmer, whose
                // intention is to render nothing.
                rendering = ""
            }
            
            if let rendering = rendering {
                var rendering = rendering
                switch (contentType, renderingContentType, escapesHTML) {
                case (.HTML, .Text, true):
                    rendering = escapeHTML(rendering)
                default:
                    break
                }
                
                buffer = buffer! + rendering
                
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender:rendering, forValue: value)
                }
                
                return true
            } else {
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender:nil, forValue: value)
                }
                
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


// =============================================================================
// MARK: - Rendering Support

extension Bool: MustacheCluster, MustacheRenderable {
    
    public var mustacheBool: Bool { return self }
    public var mustacheFilter: MustacheFilter? { return nil }
    public var mustacheInspectable: MustacheInspectable? { return nil }
    public var mustacheTagObserver: MustacheTagObserver? { return nil }
    public var mustacheRenderable: MustacheRenderable? { return self }
    
    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(self))
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            } else {
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
    }
}

extension Int: MustacheCluster, MustacheRenderable {
    
    public var mustacheBool: Bool { return self != 0 }
    public var mustacheFilter: MustacheFilter? { return nil }
    public var mustacheInspectable: MustacheInspectable? { return nil }
    public var mustacheTagObserver: MustacheTagObserver? { return nil }
    public var mustacheRenderable: MustacheRenderable? { return self }
    
    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(self))
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            } else {
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
    }
}

extension Double: MustacheCluster, MustacheRenderable {
    
    public var mustacheBool: Bool { return self != 0.0 }
    public var mustacheFilter: MustacheFilter? { return nil }
    public var mustacheInspectable: MustacheInspectable? { return nil }
    public var mustacheTagObserver: MustacheTagObserver? { return nil }
    public var mustacheRenderable: MustacheRenderable? { return self }
    
    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return "\(self)"
        case .Section:
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(self))
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            } else {
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
    }
}

extension String: MustacheCluster, MustacheRenderable, MustacheInspectable {
    
    public var mustacheBool: Bool { return countElements(self) > 0 }
    public var mustacheFilter: MustacheFilter? { return nil }
    public var mustacheInspectable: MustacheInspectable? { return self }
    public var mustacheTagObserver: MustacheTagObserver? { return nil }
    public var mustacheRenderable: MustacheRenderable? { return self }
    
    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch tag.type {
        case .Variable:
            return self
        case .Section:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(self))
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
    }
    
    public func valueForMustacheIdentifier(identifier: String) -> Value? {
        switch identifier {
        case "length":
            return Value(countElements(self))
        default:
            return nil
        }
    }
}