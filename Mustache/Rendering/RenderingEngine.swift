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

final class RenderingEngine {
    
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
    
    enum TemplateASTVisitResult {
        case Success
        case Error(NSError)
    }
    
    func visit(node: TemplateASTNode) -> TemplateASTVisitResult {
        switch node {
        case .InheritableSection(let inheritableSection):
            return visitInheritableSection(inheritableSection)
        case .InheritedPartial(let inheritedPartial):
            return visitInheritedPartial(inheritedPartial)
        case .Partial(let partial):
            return visitPartial(partial)
        case .Section(let section):
            return visitSection(section)
        case .Text(let text):
            return visitText(text)
        case .Variable(let variable):
            return visitVariable(variable)
        }
    }
    
    func visitInheritedPartial(inheritedPartial: TemplateASTNode.InheritedPartialDescriptor) -> TemplateASTVisitResult {
        let originalContext = context
        context = context.extendedContext(inheritedPartial: inheritedPartial)
        let result = visitPartial(inheritedPartial.partial)
        context = originalContext
        return result
    }
    
    func visitInheritableSection(inheritableSection: TemplateASTNode.InheritableSectionDescriptor) -> TemplateASTVisitResult {
        return visit(inheritableSection.templateAST)
    }
    
    func visitPartial(partial: TemplateASTNode.PartialDescriptor) -> TemplateASTVisitResult {
        return visit(partial.templateAST)
    }
    
    func visitVariable(variable: TemplateASTNode.VariableDescriptor) -> TemplateASTVisitResult {
        let tag = VariableTag(contentType: variable.contentType, token: variable.token)
        return visitTag(tag, escapesHTML: variable.escapesHTML, inverted: false, expression: variable.expression)
    }
    
    func visitSection(section: TemplateASTNode.SectionDescriptor) -> TemplateASTVisitResult {
        let tag = SectionTag(templateAST: section.templateAST, openingToken: section.openingToken, innerTemplateString: section.innerTemplateString)
        return visitTag(tag, escapesHTML: true, inverted: section.inverted, expression: section.expression)
    }
    
    func visitText(text: TemplateASTNode.TextDescriptor) -> TemplateASTVisitResult {
        buffer = buffer! + text.text
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
            let result = visit(node)
            switch result {
            case .Error:
                return result
            default:
                break
            }
        }
        return .Success
    }
    
    private func visitTag(tag: Tag, escapesHTML: Bool, inverted: Bool, expression: Expression) -> TemplateASTVisitResult {
        
        // Evaluate expression
        
        let expressionInvocation = ExpressionInvocation(expression: expression)
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
                if inverted {
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
