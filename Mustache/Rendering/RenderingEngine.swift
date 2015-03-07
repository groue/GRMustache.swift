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
    
    init(templateAST: TemplateAST, context: Context) {
        self.templateAST = templateAST
        self.context = context
    }
    
    func render(# error: NSErrorPointer) -> Rendering? {
        buffer = ""
        switch visit(templateAST) {
        case .Error(let visitError):
            if error != nil {
                error.memory = visitError
            }
            return nil
        default:
            return Rendering(buffer!, templateAST.contentType)
        }
    }
    
    
    // MARK: - TemplateASTVisitor
    
    func visit(inheritedPartialNode: InheritedPartialNode) -> TemplateASTVisitResult {
        let originalContext = context
        context = context.extendedContext(inheritedPartialNode: inheritedPartialNode)
        let result = visit(inheritedPartialNode.partialNode)
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
    
    private let templateAST: TemplateAST
    private var context: Context
    private var buffer: String?
    
    private func visit(templateAST: TemplateAST) -> TemplateASTVisitResult {
        let targetContentType = self.templateAST.contentType!
        if templateAST.contentType == targetContentType {
            return visit(templateAST.nodes)
        } else {
            // Render separately, so that we can HTML-escape the rendering of
            // the templateAST before appending to our buffer.
            let renderingEngine = RenderingEngine(templateAST: templateAST, context: context)
            var error: NSError?
            if let rendering = renderingEngine.render(error: &error) {
                switch (targetContentType, rendering.contentType) {
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
            let rendering: Rendering?
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
                let string: String
                switch (templateAST.contentType!, rendering.contentType, escapesHTML) {
                case (.HTML, .Text, true):
                    string = escapeHTML(rendering.string)
                default:
                    string = rendering.string
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
