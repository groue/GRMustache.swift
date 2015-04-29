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
        // We must take care of eventual content-type mismatch between the
        // currently rendered AST (defined by init), and the argument.
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
            return renderTemplateAST(resolvedSection.innerTemplateAST, inContext: context)
            
        case .InheritedPartialNode(let inheritedPartial):
            // {{< name }}...{{/ name }}
            //
            // Extend the inheritance stack, and render the content of the parent partial
            let context = context.extendedContext(inheritedPartial: inheritedPartial)
            return renderTemplateAST(inheritedPartial.parentPartial.templateAST, inContext: context)
            
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
    
    typealias InheritanceStep = (section: TemplateASTNode.InheritableSection, usedParentTemplateASTs: [TemplateAST])
    private func resolveInheritableSection(section: TemplateASTNode.InheritableSection, inContext context: Context) -> TemplateASTNode.InheritableSection {
        // As we iterate inherited partials, section becomes the deepest overriden section.
        // context.overridingTemplateASTStack has been built in renderNode(node:, inContext:).
        //
        // We also propagate an array of used parent template AST in order to support
        // nested inherited partials. See -[GRMustacheJavaSuiteTests testExtensionNested]
        let initialStep: InheritanceStep = (section: section, usedParentTemplateASTs: [])
        let resolvedStep = reduce(context.inheritedPartialStack, initialStep) { (step, inheritedPartial) in
            let avoidTemplateAST = inheritedPartial.parentPartial.templateAST
            if (contains(step.usedParentTemplateASTs) { $0 === avoidTemplateAST }) {
                // Without this test, we break -[GRMustacheJavaSuiteTests testExtensionNested]
                // TODO: write a test in GRMustache suites.
                return step
            }
            return resolveInheritableSection(
                step,
                inOverridingTemplateAST:inheritedPartial.overridingTemplateAST,
                usingInheritedPartial: inheritedPartial)
        }
        return resolvedStep.section
    }
    
    // Looks for an override for the section argument in a TemplateAST.
    private func resolveInheritableSection(
        step: InheritanceStep,
        inOverridingTemplateAST overridingTemplateAST: TemplateAST,
        usingInheritedPartial usedInheritedPartial: TemplateASTNode.InheritedPartial)
        -> InheritanceStep
    {
        // As we iterate template AST nodes, section becomes the last inherited
        // section in the template AST.
        return reduce(overridingTemplateAST.nodes, step) { (step, node) in
            switch node {
            case .InheritableSectionNode(let resolvedSection) where resolvedSection.name == step.section.name:
                // {{$ name }}...{{/ name }}
                //
                // An inheritable section is overriden by another inheritable section with the same name.
                // And we use usedInheritedPartial.parentPartial.templateAST.
                //
                // If we would not use usedInheritedPartial.parentPartial.templateAST,
                // we break -[GRMustacheJavaSuiteTests testExtensionNested]
                // TODO: write a test in GRMustache suites.
                return (section: resolvedSection, step.usedParentTemplateASTs + [usedInheritedPartial.parentPartial.templateAST])
                
            case .InheritedPartialNode(let inheritedPartial):
                // {{< partial }}...{{/ partial }}
                //
                // Inherited partials can provide an override in two ways: in
                // the parent partial, and inside the overriding section.
                //
                // Relevant tests:
                //
                // {
                //   "name": "Two levels of inheritance: inherited partial with overriding content containing another inherited partial",
                //   "data": { },
                //   "template": "{{<partial}}{{<partial2}}{{/partial2}}{{/partial}}",
                //   "partials": {
                //       "partial": "{{$inheritable}}ignored{{/inheritable}}",
                //       "partial2": "{{$inheritable}}inherited{{/inheritable}}" },
                //   "expected": "inherited"
                // },
                // {
                //   "name": "Two levels of inheritance: inherited partial with overriding content containing another inherited partial with overriding content containing an inheritable section",
                //   "data": { },
                //   "template": "{{<partial}}{{<partial2}}{{$inheritable}}inherited{{/inheritable}}{{/partial2}}{{/partial}}",
                //   "partials": {
                //       "partial": "{{$inheritable}}ignored{{/inheritable}}",
                //       "partial2": "{{$inheritable}}ignored{{/inheritable}}" },
                //   "expected": "inherited"
                // }
                
                let step1 = resolveInheritableSection(
                    step,
                    inOverridingTemplateAST: inheritedPartial.parentPartial.templateAST,
                    usingInheritedPartial: usedInheritedPartial)
                let step2 = resolveInheritableSection(
                    step1,
                    inOverridingTemplateAST: inheritedPartial.overridingTemplateAST,
                    usingInheritedPartial: usedInheritedPartial)
                return step2
                
            case .PartialNode(let partial):
                // {{> partial }}
                //
                // Relevant test:
                //
                // {
                //   "name": "Partials in inherited partials can override inheritable sections",
                //   "data": { },
                //   "template": "{{<partial2}}{{>partial1}}{{/partial2}}",
                //   "partials": {
                //       "partial1": "{{$inheritable}}partial1{{/inheritable}}",
                //       "partial2": "{{$inheritable}}ignored{{/inheritable}}" },
                //   "expected": "partial1"
                // },
                return resolveInheritableSection(step, inOverridingTemplateAST: partial.templateAST, usingInheritedPartial: usedInheritedPartial)
                
            default:
                // Other nodes can't override the section.
                //
                // Make sure we do not return a step where usedInheritedPartial.parentPartial.templateAST
                // would be used: it would make the "Recursion in inherited templates" test fail.
                return step
            }
        }
    }
}
