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
            return DefaultConfiguration.contentType
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
        case .Success(var box):
            
            for willRender in context.willRenderStack {
                box = willRender(tag: tag, box: box)
            }
            
            let info = RenderingInfo(tag: tag, context: context, enumerationItem: false)
            var error: NSError?
            var rendering: Rendering?
            switch tag.type {
            case .Variable:
                rendering = box.render(info: info, error: &error)
            case .Section:
                if tag.inverted {
                    if box.boolValue {
                        rendering = Rendering("")
                    } else {
                        rendering = info.tag.renderInnerContent(info.context, error: &error)
                    }
                } else {
                    if box.boolValue {
                        rendering = box.render(info: info, error: &error)
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
                
                for didRender in context.didRenderStack {
                    didRender(tag: tag, box: box, string: string)
                }
                
                return .Success
            } else {
                for didRender in context.didRenderStack {
                    didRender(tag: tag, box: box, string: nil)
                }
                
                return .Error(error!)
            }
        }
    }
}
