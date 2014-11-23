//
//  RenderingEngine.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public struct RenderingInfo {
    public let tag: Tag
    public let context: Context
    let enumerationItem: Bool
    
    public func renderingInfoByExtendingContextWithValue(value: Value) -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context.contextByAddingValue(value), enumerationItem: enumerationItem)
    }
    
    public func renderingInfoByExtendingContextWithTagObserver(tagObserver: MustacheTagObserver) -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context.contextByAddingTagObserver(tagObserver), enumerationItem: enumerationItem)
    }
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context, enumerationItem: true)
    }
    
    public func render(_ context: Context? = nil) -> Rendering {
        return tag.render(context ?? self.context)
    }
}

public enum ContentType {
    case Text
    case HTML
}

public enum Rendering {
    case Error(NSError)
    case Success(String, ContentType)
}

class RenderingEngine: TemplateASTVisitor {
    let contentType: ContentType
    var context: Context
    var buffer: String?
    
    init(contentType: ContentType, context: Context) {
        self.contentType = contentType
        self.context = context
    }
    
    func render(templateAST: TemplateAST) -> Rendering {
        buffer = ""
        var error: NSError?
        if !visit(templateAST, error: &error) {
            return .Error(error!)
        }
        return .Success(buffer!, contentType)
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
            let rendering = renderingEngine.render(templateAST)
            switch rendering {
            case .Error(let error):
                if outError != nil {
                    outError.memory = error
                }
                return false
            case .Success(let string, let renderingContentType):
                switch (contentType, renderingContentType) {
                case (.HTML, .Text):
                    buffer = buffer! + escapeHTML(string)
                default:
                    buffer = buffer! + string
                }
                return true
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
            
            let renderingInfo = RenderingInfo(tag: tag, context: context, enumerationItem: false)
            var rendering: Rendering
            switch tag.type {
            case .Variable:
                rendering = value.render(renderingInfo)
            case .Section:
                let boolValue = value.mustacheBool
                if tag.inverted {
                    if boolValue {
                        rendering = .Success("", .Text)
                    } else {
                        rendering = renderingInfo.render()
                    }
                } else {
                    if boolValue {
                        rendering = value.render(renderingInfo)
                    } else {
                        rendering = .Success("", .Text)
                    }
                }
            }
            
            switch rendering {
            case .Error(let error):
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender:nil, forValue: value)
                }
                
                if outError != nil {
                    outError.memory = error
                }
                return false
            case .Success(var string, let renderingContentType):
                switch (contentType, renderingContentType, escapesHTML) {
                case (.HTML, .Text, true):
                    string = escapeHTML(string)
                default:
                    break
                }
                
                buffer = buffer! + string
                
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender:string, forValue: value)
                }
                
                return true
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
    
    public func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        switch renderingInfo.tag.type {
        case .Variable:
            return .Success("\(self)", .Text)
        case .Section:
            if renderingInfo.enumerationItem {
                return renderingInfo.render(renderingInfo.context.contextByAddingValue(Value(self)))
            } else {
                return renderingInfo.render()
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
    
    public func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        switch renderingInfo.tag.type {
        case .Variable:
            return .Success("\(self)", .Text)
        case .Section:
            if renderingInfo.enumerationItem {
                return renderingInfo.render(renderingInfo.context.contextByAddingValue(Value(self)))
            } else {
                return renderingInfo.render()
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
    
    public func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        switch renderingInfo.tag.type {
        case .Variable:
            return .Success("\(self)", .Text)
        case .Section:
            if renderingInfo.enumerationItem {
                return renderingInfo.render(renderingInfo.context.contextByAddingValue(Value(self)))
            } else {
                return renderingInfo.render()
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
    
    public func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        switch renderingInfo.tag.type {
        case .Variable:
            return .Success(self, .Text)
        case .Section:
            return renderingInfo.render(renderingInfo.context.contextByAddingValue(Value(self)))
        }
    }
    
    public func valueForMustacheKey(key: String) -> Value? {
        switch key {
        case "length":
            return Value(countElements(self))
        default:
            return nil
        }
    }
}