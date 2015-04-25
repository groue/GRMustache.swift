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
    case InheritableSection(InheritableSectionDescriptor)   // {{$ name }}...{{/ name }}
    case InheritedPartial(InheritedPartialDescriptor)       // {{< name }}...{{/ name }}
    case Partial(PartialDescriptor)                         // {{> name }}
    case Section(SectionDescriptor)                         // {{# name }}...{{/ name }}, {{^ name }}...{{/ name }}
    case Text(String)                                       // text
    case Variable(VariableDescriptor)                       // {{ name }}, {{{ name }}}, {{& name }}
    
    
    // Define structs instead of long tuples
    
    struct InheritableSectionDescriptor {
        let templateAST: TemplateAST
        let name: String
    }
    
    struct InheritedPartialDescriptor {
        let templateAST: TemplateAST
        let partial: PartialDescriptor
    }
    
    struct PartialDescriptor {
        let templateAST: TemplateAST
        let name: String?
    }
    
    struct SectionDescriptor {
        let tag: SectionTag
        let expression: Expression
        let inverted: Bool
    }
    
    struct VariableDescriptor {
        let tag: VariableTag
        let expression: Expression
        let escapesHTML: Bool
    }
    
    
    // Factory methods
    
    static func inheritableSection(# templateAST: TemplateAST, name: String) -> TemplateASTNode {
        return .InheritableSection(InheritableSectionDescriptor(templateAST: templateAST, name: name))
    }
    
    static func inheritedPartial(# templateAST: TemplateAST, inheritedTemplateAST: TemplateAST, inheritedPartialName: String?) -> TemplateASTNode {
        return .InheritedPartial(InheritedPartialDescriptor(templateAST: templateAST, partial: PartialDescriptor(templateAST: inheritedTemplateAST, name: inheritedPartialName)))
    }
    
    static func partial(# templateAST: TemplateAST, name: String?) -> TemplateASTNode {
        return .Partial(PartialDescriptor(templateAST: templateAST, name: name))
    }
    
    static func section(# templateAST: TemplateAST, expression: Expression, inverted: Bool, openingToken: TemplateToken, innerTemplateString: String) -> TemplateASTNode {
        let tag = SectionTag(templateAST: templateAST, openingToken: openingToken, innerTemplateString: innerTemplateString)
        return .Section(SectionDescriptor(tag: tag, expression: expression, inverted: inverted))
    }
    
    static func text(# text: String) -> TemplateASTNode {
        return .Text(text)
    }
    
    static func variable(# expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) -> TemplateASTNode {
        let tag = VariableTag(contentType: contentType, token: token)
        return .Variable(VariableDescriptor(tag: tag, expression: expression, escapesHTML: escapesHTML))
    }
}
