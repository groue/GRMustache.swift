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
    
    private func renderTemplateAST(templateAST: TemplateAST, inContext context: Context) -> RenderResult {
        // TemplateAST carry a content-type.
        //
        // We must take care of content type mismatch between the currently
        // rendered AST (defined by init), and the argument.
        //
        // For example, the partial loaded by the HTML template `{{>partial}}`
        // may be a text one. In this case, we must render the partial as text,
        // and then HTML-encode its rendering. See the "Partial containing
        // CONTENT_TYPE:TEXT pragma is HTML-escaped when embedded." test in
        // the text_rendering.json test suite.
        //
        // So let's check for a content-type mismatch:
        
        let targetContentType = self.templateAST.contentType!
        if templateAST.contentType == targetContentType
        {
            // Content-type match
            
            for node in templateAST.nodes {
                let result = renderNode(node, inContext: context)
                switch result {
                case .Error:
                    return result
                default:
                    break
                }
            }
            return .Success
        }
        else
        {
            // Content-type mismatch
            //
            // Render separately, so that we can HTML-escape the rendering of
            // the templateAST before appending to our buffer.
            let renderingEngine = RenderingEngine(templateAST: templateAST, context: context)
            var error: NSError?
            if let rendering = renderingEngine.render(error: &error) {
                switch (targetContentType, rendering.contentType) {
                case (.HTML, .Text):
                    buffer.extend(escapeHTML(rendering.string))
                default:
                    buffer.extend(rendering.string)
                }
                return .Success
            } else {
                return .Error(error!)
            }
        }
    }
    
    private func renderNode(node: TemplateASTNode, inContext context: Context) -> RenderResult {
        switch node {
        case .InheritableSectionNode(let inheritableSection):
            // {{$ name }}...{{/ name }}
            //
            // Render the inner content of the resolved inheritable section.
            let resolvedSection = resolveInheritableSection(inheritableSection, inContext: context)
            return renderTemplateAST(resolvedSection.templateAST, inContext: context)
            
        case .InheritedPartialNode(let inheritedPartial):
            // {{< name }}...{{/ name }}
            //
            // Extend the inheritance stack, and render the content of the partial
            let context = context.extendedContext(inheritedPartial: inheritedPartial)
            return renderTemplateAST(inheritedPartial.partial.templateAST, inContext: context)
            
        case .PartialNode(let partial):
            // {{> name }}
            //
            // Render the content of the partial
            return renderTemplateAST(partial.templateAST, inContext: context)
            
        case .SectionNode(let section):
            // {{# name }}...{{/ name }}
            // {{^ name }}...{{/ name }}
            //
            // We have common rendering for sections and variable tags, yet with
            // a few specific flags:
            return renderTag(section.tag, escapesHTML: true, inverted: section.inverted, expression: section.expression, inContext: context)
            
        case .TextNode(let text):
            // text is the trivial case:
            buffer.extend(text)
            return .Success
            
        case .VariableNode(let variable):
            // {{ name }}
            // {{{ name }}}
            // {{& name }}
            //
            // We have common rendering for sections and variable tags, yet with
            // a few specific flags:
            return renderTag(variable.tag, escapesHTML: variable.escapesHTML, inverted: false, expression: variable.expression, inContext: context)
        }
    }
    
    private func renderTag(tag: Tag, escapesHTML: Bool, inverted: Bool, expression: Expression, inContext context: Context) -> RenderResult {
        
        // 1. Evaluate expression
        
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
            
            // 2. Let willRender functions alter the box
            
            for willRender in context.willRenderStack {
                box = willRender(tag: tag, box: box)
            }
            
            
            // 3. Render the box
            
            var error: NSError?
            let rendering: Rendering?
            switch tag.type {
            case .Variable:
                let info = RenderingInfo(tag: tag, context: context, enumerationItem: false)
                rendering = box.render(info: info, error: &error)
            case .Section:
                switch (inverted, box.boolValue) {
                case (false, true):
                    // {{# true }}...{{/ true }}
                    // Only case where we trigger the RenderFunction of the Box
                    let info = RenderingInfo(tag: tag, context: context, enumerationItem: false)
                    rendering = box.render(info: info, error: &error)
                case (true, false):
                    // {{^ false }}...{{/ false }}
                    rendering = tag.renderInnerContent(context, error: &error)
                default:
                    // {{^ true }}...{{/ true }}
                    // {{# false }}...{{/ false }}
                    rendering = Rendering("")
                }
            }
            
            if let rendering = rendering {
                
                // 4. Extend buffer with the rendering, HTML-escaped if needed.
                
                let string: String
                switch (templateAST.contentType!, rendering.contentType, escapesHTML) {
                case (.HTML, .Text, true):
                    string = escapeHTML(rendering.string)
                default:
                    string = rendering.string
                }
                buffer.extend(string)
                
                
                // 5. Let didRender functions do their job
                
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
    
    private func resolveInheritableSection(section: TemplateASTNode.InheritableSection, inContext context: Context) -> TemplateASTNode.InheritableSection {
        let inheritedPartialStack = context.inheritedPartialStack
        
        // Iterate all inherited partials, and carry along a (section, templateASTs) tuple.
        //
        // The tuple contains the last resolved section, and an array of template ASTS which
        // have actually overriden the section. They help putting an end to recursive inheritance.
        let (resolvedSection, _) = reduce(inheritedPartialStack, (section, [] as [TemplateAST])) { (tuple, inheritedPartial) in
            let (section, superTemplateASTs) = tuple
            let templateAST = inheritedPartial.partial.templateAST
            
            // Don't resolve twice against the same AST
            if !contains(superTemplateASTs, { $0 === templateAST }) {
                let (resolvedSection, modified) = resolveInheritableSection(section, againstInheritedPartial: inheritedPartial, inContext: context)
                if modified {
                    return (resolvedSection, superTemplateASTs + [templateAST])
                }
            }
            return tuple
        }
        return resolvedSection
    }
    
    // Returns a tuple (section, modified) where modified is true if and only if
    // the section has been overriden.
    private func resolveInheritableSection(section: TemplateASTNode.InheritableSection, againstNode inheritedNode: TemplateASTNode, inContext context: Context) -> (TemplateASTNode.InheritableSection, Bool) {
        switch inheritedNode {
        case .InheritableSectionNode(let inheritableSection) where inheritableSection.name == section.name:
            // Found an override!
            return (inheritableSection, true)
        case .InheritedPartialNode(let inheritedPartial):
            return resolveInheritableSection(section, againstInheritedPartial: inheritedPartial, inContext: context)
        case .PartialNode(let partial):
            return reduce(partial.templateAST.nodes, (section, false)) { (pair, inheritedNode) in
                let (section, modified) = pair
                let (resolvedSection, resolvedModified) = resolveInheritableSection(section, againstNode: inheritedNode, inContext: context)
                return (resolvedSection, modified || resolvedModified)
            }
        default:
            return (section, false)
        }
    }
    
    // Returns a tuple (section, modified) where modified is true if and only if
    // the section has been overriden.
    private func resolveInheritableSection(section: TemplateASTNode.InheritableSection, againstInheritedPartial inheritedPartial: TemplateASTNode.InheritedPartial, inContext context: Context) -> (TemplateASTNode.InheritableSection, Bool) {
        return reduce(inheritedPartial.templateAST.nodes, (section, false)) { (pair, inheritedNode) in
            let (section, modified) = pair
            let (resolvedSection, resolvedModified) = resolveInheritableSection(section, againstNode: inheritedNode, inContext: context)
            return (resolvedSection, modified || resolvedModified)
        }
    }
}
