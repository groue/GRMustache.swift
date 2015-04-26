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

enum TemplateASTNode {
    case InheritableSectionNode(InheritableSection) // {{$ name }}...{{/ name }}
    case InheritedPartialNode(InheritedPartial)     // {{< name }}...{{/ name }}
    case PartialNode(Partial)                       // {{> name }}
    case SectionNode(Section)                       // {{# name }}...{{/ name }}, {{^ name }}...{{/ name }}
    case TextNode(String)                           // text
    case VariableNode(Variable)                     // {{ name }}, {{{ name }}}, {{& name }}
    
    
    // Define structs instead of long tuples
    
    struct InheritableSection {
        let templateAST: TemplateAST
        let name: String
    }
    
    struct InheritedPartial {
        let templateAST: TemplateAST
        let partial: Partial
    }
    
    struct Partial {
        let templateAST: TemplateAST
        let name: String?
    }
    
    struct Section {
        let tag: SectionTag
        let expression: Expression
        let inverted: Bool
    }
    
    struct Variable {
        let tag: VariableTag
        let expression: Expression
        let escapesHTML: Bool
    }
    
    
    // Factory methods
    
    static func inheritableSection(# templateAST: TemplateAST, name: String) -> TemplateASTNode {
        return .InheritableSectionNode(InheritableSection(templateAST: templateAST, name: name))
    }
    
    static func inheritedPartial(# templateAST: TemplateAST, inheritedTemplateAST: TemplateAST, inheritedPartialName: String?) -> TemplateASTNode {
        return .InheritedPartialNode(InheritedPartial(templateAST: templateAST, partial: Partial(templateAST: inheritedTemplateAST, name: inheritedPartialName)))
    }
    
    static func partial(# templateAST: TemplateAST, name: String?) -> TemplateASTNode {
        return .PartialNode(Partial(templateAST: templateAST, name: name))
    }
    
    static func section(# templateAST: TemplateAST, expression: Expression, inverted: Bool, openingToken: TemplateToken, innerTemplateString: String) -> TemplateASTNode {
        let tag = SectionTag(templateAST: templateAST, openingToken: openingToken, innerTemplateString: innerTemplateString)
        return .SectionNode(Section(tag: tag, expression: expression, inverted: inverted))
    }
    
    static func text(# text: String) -> TemplateASTNode {
        return .TextNode(text)
    }
    
    static func variable(# expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) -> TemplateASTNode {
        let tag = VariableTag(contentType: contentType, token: token)
        return .VariableNode(Variable(tag: tag, expression: expression, escapesHTML: escapesHTML))
    }
}
