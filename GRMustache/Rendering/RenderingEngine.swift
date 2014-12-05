//
//  RenderingEngine.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public struct RenderingInfo {
    public let tag: Tag
    public var context: Context
    let enumerationItem: Bool
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context, enumerationItem: true)
    }
}

public enum ContentType {
    case Text
    case HTML
}

public struct Rendering {
    public var string: String
    public var contentType: ContentType
    
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
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
    
    func render(templateAST: TemplateAST, error: NSErrorPointer) -> Rendering? {
        buffer = ""
        switch visit(templateAST) {
        case .Error(let visitError):
            if error != nil {
                error.memory = visitError
            }
            return nil
        default:
            return Rendering(buffer!, contentType)
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
            var error: NSError?
            if let rendering = renderingEngine.render(templateAST, error: &error) {
                switch (contentType, rendering.contentType) {
                case (.HTML, .Text):
                    buffer = buffer! + escapeHTML(rendering.string)
                default:
                    buffer = buffer! + rendering.string
                }
                return .Success
            } else {
                return .Error(error!)
            }
        }
    }
    
    func visit(inheritablePartialNode: InheritablePartialNode) -> TemplateASTVisitResult {
        let originalContext = context
        context = context.extendedContext(inheritablePartialNode: inheritablePartialNode)
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
    
    private func visit(tag: Tag, escapesHTML: Bool) -> TemplateASTVisitResult {
        
        // Evaluate expression
        
        let expressionInvocation = ExpressionInvocation(expression: tag.expression)
        let invocationResult = expressionInvocation.invokeWithContext(context)
        switch invocationResult {
        case .Error(let error):
            var userInfo = error.userInfo ?? [:]
            if let originalLocalizedDescription: AnyObject = userInfo[NSLocalizedDescriptionKey] {
                userInfo[NSLocalizedDescriptionKey] = "Error evaluating \(tag.description): \(originalLocalizedDescription)"
            } else {
                userInfo[NSLocalizedDescriptionKey] = "Error evaluating \(tag.description)"
            }
            return .Error(NSError(domain: error.domain, code: error.code, userInfo: userInfo))
        case .Success(var value):
            
            let tagObserverStack = context.tagObserverStack
            for tagObserver in tagObserverStack {
                value = tagObserver.mustacheTag(tag, willRender: value)
            }
            
            let info = RenderingInfo(tag: tag, context: context, enumerationItem: false)
            var error: NSError?
            var rendering: Rendering?
            switch tag.type {
            case .Variable:
                rendering = value.render(info, error: &error)
            case .Section:
                let boolValue = value.mustacheBool
                if tag.inverted {
                    if boolValue {
                        rendering = Rendering("")
                    } else {
                        rendering = info.tag.render(info.context, error: &error)
                    }
                } else {
                    if boolValue {
                        rendering = value.render(info, error: &error)
                    } else {
                        rendering = Rendering("")
                    }
                }
            }
            
            if let rendering = rendering {
                var string = rendering.string
                switch (contentType, rendering.contentType, escapesHTML) {
                case (.HTML, .Text, true):
                    string = escapeHTML(string)
                default:
                    break
                }
                
                buffer = buffer! + string
                
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender: value, asString: string)
                }
                
                return .Success
            } else {
                for tagObserver in tagObserverStack.reverse() {
                    tagObserver.mustacheTag(tag, didRender: value, asString: nil)
                }
                
                return .Error(error!)
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
    
    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(box: Box(self)), error: error)
            } else {
                return info.tag.render(info.context, error: error)
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
    
    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(box: Box(self)), error: error)
            } else {
                return info.tag.render(info.context, error: error)
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
    
    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering("\(self)")
        case .Section:
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(box: Box(self)), error: error)
            } else {
                return info.tag.render(info.context, error: error)
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
    
    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            return Rendering(self)
        case .Section:
            return info.tag.render(info.context.extendedContext(box: Box(self)), error: error)
        }
    }
    
    public func valueForMustacheKey(key: String) -> Box? {
        switch key {
        case "length":
            return Box(countElements(self))
        default:
            return nil
        }
    }
}
