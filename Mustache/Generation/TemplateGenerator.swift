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


extension TemplateAST : DebugPrintable {
    var debugDescription: String {
        return TemplateGenerator().stringFromTemplateAST(self)
    }
}

extension Template : DebugPrintable {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return TemplateGenerator().stringFromTemplateAST(templateAST)
    }
}

private class TemplateGenerator {
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
        case .InheritableSectionNode(let inheritableSection):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = inheritableSection.name
            buffer.extend("\(tagStartDelimiter)$\(name)\(tagEndDelimiter)")
            renderTemplateAST(inheritableSection.innerTemplateAST)
            buffer.extend("\(tagStartDelimiter)/\(name)\(tagEndDelimiter)")
            
        case .InheritedPartialNode(let inheritedPartial):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = inheritedPartial.parentPartial.name ?? "<null>"
            buffer.extend("\(tagStartDelimiter)<\(name)\(tagEndDelimiter)")
            renderTemplateAST(inheritedPartial.overridingTemplateAST)
            buffer.extend("\(tagStartDelimiter)/\(name)\(tagEndDelimiter)")
            
        case .PartialNode(let partial):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let name = partial.name ?? "<null>"
            buffer.extend("\(tagStartDelimiter)>\(name)\(tagEndDelimiter)")
            
        case .SectionNode(let section):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let expression = "TODO"
            if section.inverted {
                buffer.extend("\(tagStartDelimiter)^\(expression)\(tagEndDelimiter)")
            } else {
                buffer.extend("\(tagStartDelimiter)#\(expression)\(tagEndDelimiter)")
            }
            renderTemplateAST(section.tag.innerTemplateAST)
            buffer.extend("\(tagStartDelimiter)/\(expression)\(tagEndDelimiter)")
            
        case .TextNode(let text):
            buffer.extend(text)
            
        case .VariableNode(let variable):
            let tagStartDelimiter = configuration.tagDelimiterPair.0
            let tagEndDelimiter = configuration.tagDelimiterPair.1
            let expression = "TODO"
            if variable.escapesHTML {
                buffer.extend("\(tagStartDelimiter)&\(expression)\(tagEndDelimiter)")
            } else {
                buffer.extend("\(tagStartDelimiter)\(expression)\(tagEndDelimiter)")
            }
        }
    }
    
    private var buffer: String = ""
}
