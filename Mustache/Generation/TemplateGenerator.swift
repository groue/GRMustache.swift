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


extension TemplateAST : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription: String {
        let string = TemplateGenerator().stringFromTemplateAST(self)
        return "TemplateAST(\(string.debugDescription))"
    }
}

extension Template : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        let string = TemplateGenerator().stringFromTemplateAST(templateAST)
        return "Template(\(string.debugDescription))"
    }
}

final class TemplateGenerator {
    let configuration: Configuration
    
    init(configuration: Configuration? = nil) {
        self.configuration = configuration ?? DefaultConfiguration
    }
    
    func stringFromTemplateAST(templateAST: TemplateAST) -> String {
        buffer = ""
        renderTemplateAST(templateAST)
        return buffer
    }
    
    private func renderTemplateAST(templateAST: TemplateAST) {
        for node in templateAST.nodes {
            renderTemplateASTNode(node)
        }
    }
    
    func renderTemplateASTNode(node: TemplateASTNode) {
        switch node {
        case .BlockNode(let block):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = block.name
            buffer.appendContentsOf("\(tagStartDelimiter)$\(name)\(tagEndDelimiter)")
            renderTemplateAST(block.innerTemplateAST)
            buffer.appendContentsOf("\(tagStartDelimiter)/\(name)\(tagEndDelimiter)")
            
        case .PartialOverrideNode(let partialOverride):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = partialOverride.parentPartial.name ?? "<null>"
            buffer.appendContentsOf("\(tagStartDelimiter)<\(name)\(tagEndDelimiter)")
            renderTemplateAST(partialOverride.childTemplateAST)
            buffer.appendContentsOf("\(tagStartDelimiter)/\(name)\(tagEndDelimiter)")
            
        case .PartialNode(let partial):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = partial.name ?? "<null>"
            buffer.appendContentsOf("\(tagStartDelimiter)>\(name)\(tagEndDelimiter)")
            
        case .SectionNode(let section):
            // Change delimiters tags are ignored. Always use configuration tag
            // delimiters.
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let expression = ExpressionGenerator().stringFromExpression(section.expression)
            if section.inverted {
                buffer.appendContentsOf("\(tagStartDelimiter)^\(expression)\(tagEndDelimiter)")
            } else {
                buffer.appendContentsOf("\(tagStartDelimiter)#\(expression)\(tagEndDelimiter)")
            }
            renderTemplateAST(section.tag.innerTemplateAST)
            buffer.appendContentsOf("\(tagStartDelimiter)/\(expression)\(tagEndDelimiter)")
            
        case .TextNode(let text):
            buffer.appendContentsOf(text)
            
        case .VariableNode(let variable):
            // Change delimiters tags are ignored. Always use configuration tag
            // delimiters.
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let expression = ExpressionGenerator().stringFromExpression(variable.expression)
            if variable.escapesHTML {
                buffer.appendContentsOf("\(tagStartDelimiter)\(expression)\(tagEndDelimiter)")
            } else if tagStartDelimiter == "{{" && tagEndDelimiter == "}}" {
                buffer.appendContentsOf("\(tagStartDelimiter){\(expression)}\(tagEndDelimiter)")
            } else {
                buffer.appendContentsOf("\(tagStartDelimiter)&\(expression)\(tagEndDelimiter)")
            }
        }
    }
    
    private var buffer: String = ""
}
