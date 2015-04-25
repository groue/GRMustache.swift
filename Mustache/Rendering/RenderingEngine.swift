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
        self.baseContext = context
        buffer = ""
    }
    
    func render(# error: NSErrorPointer) -> Rendering? {
        buffer = ""
        switch renderTemplateAST(templateAST, inContext: baseContext) {
        case .Error(let renderError):
            if error != nil {
                error.memory = renderError
            }
            return nil
        default:
            return Rendering(buffer, templateAST.contentType)
        }
    }
    
    
    // MARK: - Rendering
    
    private let templateAST: TemplateAST
    private let baseContext: Context
    private var buffer: String

    private enum RenderResult {
        case Success
        case Error(NSError)
    }
    
    private func renderNode(node: TemplateASTNode, inContext context: Context) -> RenderResult {
        switch node {
        case .InheritableSection(let inheritableSection):
            return renderTemplateAST(inheritableSection.templateAST, inContext: context)
        case .InheritedPartial(let inheritedPartial):
            return renderTemplateAST(inheritedPartial.partial.templateAST, inContext: context.extendedContext(inheritedPartial: inheritedPartial))
        case .Partial(let partial):
            return renderTemplateAST(partial.templateAST, inContext: context)
        case .Section(let section):
            return renderTag(section.tag, escapesHTML: true, inverted: section.inverted, expression: section.expression, inContext: context)
        case .Text(let text):
            buffer += text
            return .Success
        case .Variable(let variable):
            return renderTag(variable.tag, escapesHTML: variable.escapesHTML, inverted: false, expression: variable.expression, inContext: context)
        }
    }
    
    private func renderTemplateAST(templateAST: TemplateAST, inContext context: Context) -> RenderResult {
        let targetContentType = self.templateAST.contentType!
        if templateAST.contentType == targetContentType {
            for node in templateAST.nodes {
                let node = resolveNode(node, inContext: context)
                let result = renderNode(node, inContext: context)
                switch result {
                case .Error:
                    return result
                default:
                    break
                }
            }
            return .Success
        } else {
            // Render separately, so that we can HTML-escape the rendering of
            // the templateAST before appending to our buffer.
            let renderingEngine = RenderingEngine(templateAST: templateAST, context: context)
            var error: NSError?
            if let rendering = renderingEngine.render(error: &error) {
                switch (targetContentType, rendering.contentType) {
                case (.HTML, .Text):
                    buffer += escapeHTML(rendering.string)
                default:
                    buffer += rendering.string
                }
                return .Success
            } else {
                return .Error(error!)
            }
        }
    }
    
    private func renderTag(tag: Tag, escapesHTML: Bool, inverted: Bool, expression: Expression, inContext context: Context) -> RenderResult {
        
        switch ExpressionInvocation(expression: expression).invokeWithContext(context) {
            
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
                
                buffer += string
                
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
    
    
    // MARK: - Template inheritance
    
    private func resolveNode(node: TemplateASTNode, inContext context: Context) -> TemplateASTNode {
        let step: (TemplateASTNode, [TemplateAST]) = (node, [])
        let (resolvedNode, _) = reduce(context.inheritedPartialStack, step) { (step, inheritedPartial) in
            let (node, usedTemplateASTs) = step
            let templateAST = inheritedPartial.partial.templateAST
            if !contains(usedTemplateASTs, { $0 === templateAST }) {
                let (resolvedNode, modified) = resolveNode(node, againstInheritedPartial: inheritedPartial, inContext: context)
                if modified {
                    return (resolvedNode, usedTemplateASTs + [templateAST])
                }
            }
            return step
        }
        return resolvedNode
    }
    
    private func resolveNode(node: TemplateASTNode, againstNode inheritedNode: TemplateASTNode, inContext context: Context) -> (TemplateASTNode, Bool) {
        switch inheritedNode {
        case .InheritableSection(let inheritableSection):
            switch node {
            case .InheritableSection(let otherInheritableSection) where otherInheritableSection.name == inheritableSection.name:
                return (.InheritableSection(inheritableSection), true)
            default:
                return (node, false)
            }
        case .InheritedPartial(let inheritedPartial):
            return resolveNode(node, againstInheritedPartial: inheritedPartial, inContext: context)
        case .Partial(let partial):
            return reduce(partial.templateAST.nodes, (node, false)) { (pair, inheritedNode) in
                let (node, modified) = pair
                let (resolvedNode, resolvedModified) = resolveNode(node, againstNode: inheritedNode, inContext: context)
                return (resolvedNode, modified || resolvedModified)
            }
        case .Section, .Text, .Variable:
            return (node, false)
        }
    }
    
    private func resolveNode(node: TemplateASTNode, againstInheritedPartial inheritedPartial: TemplateASTNode.InheritedPartialDescriptor, inContext context: Context) -> (TemplateASTNode, Bool) {
        return reduce(inheritedPartial.templateAST.nodes, (node, false)) { (pair, inheritedNode) in
            let (node, modified) = pair
            let (resolvedNode, resolvedModified) = resolveNode(node, againstNode: inheritedNode, inContext: context)
            return (resolvedNode, modified || resolvedModified)
        }
    }
}
