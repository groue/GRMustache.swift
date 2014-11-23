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
        switch visit(templateAST) {
        case .Error(let error):
            return .Error(error)
        default:
            return .Success(buffer!, contentType)
        }
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
    
    func visit(templateAST: TemplateAST) -> TemplateASTVisitResult {
        let ASTContentType = templateAST.contentType
        
        if contentType == ASTContentType {
            RenderingEngine.pushCurrentContentType(ASTContentType)
            let result = visit(templateAST.nodes)
            RenderingEngine.popCurrentContentType()
            return result
        } else {
            // Render separately
            let renderingEngine = RenderingEngine(contentType: ASTContentType, context: context)
            let rendering = renderingEngine.render(templateAST)
            switch rendering {
            case .Error(let error):
                return .Error(error)
            case .Success(let string, let renderingContentType):
                switch (contentType, renderingContentType) {
                case (.HTML, .Text):
                    buffer = buffer! + escapeHTML(string)
                default:
                    buffer = buffer! + string
                }
                return .Success
            }
        }
    }
    
    func visit(inheritablePartialNode: InheritablePartialNode) -> TemplateASTVisitResult {
        let originalContext = context
        context = context.contextByAddingInheritablePartialNode(inheritablePartialNode)
        let result = visit(inheritablePartialNode.partialNode)
        context = originalContext
        return result
    }
    
    func visit(inheritableSectionNode: InheritableSectionNode) -> TemplateASTVisitResult {
        return visit(inheritableSectionNode.templateAST)
    }
    
    func visit(partialNode: PartialNode) -> TemplateASTVisitResult {
        return visit(partialNode.templateAST)
    }
    
    func visit(variableTag: VariableTag) -> TemplateASTVisitResult {
        return visit(variableTag, escapesHTML: variableTag.escapesHTML)
    }
    
    func visit(sectionTag: SectionTag) -> TemplateASTVisitResult {
        return visit(sectionTag, escapesHTML: true)
    }
    
    func visit(textNode: TextNode) -> TemplateASTVisitResult {
        buffer = buffer! + textNode.text
        return .Success
    }
    
    
    // MARK: - Private
    
    private func visit(nodes: [TemplateASTNode]) -> TemplateASTVisitResult {
        for node in nodes {
            let node = context.resolveTemplateASTNode(node)
            let result = node.acceptTemplateASTVisitor(self)
            switch result {
            case .Error:
                return result
            default:
                break
            }
        }
        return .Success
    }
    
    private func visit(tag: MustacheExpressionTag, escapesHTML: Bool) -> TemplateASTVisitResult {
        
        // Evaluate expression
        
        let expressionInvocation = ExpressionInvocation(expression: tag.expression)
        let invocationResult = expressionInvocation.invokeWithContext(context)
        switch invocationResult {
        case .Error(let error):
            return .Error(error)
        case .Success(var value):
            
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
                
                return .Error(error)
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
                
                return .Success
            }
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