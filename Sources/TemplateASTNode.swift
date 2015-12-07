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
    case BlockNode(Block)                       // {{$ name }}...{{/ name }}
    case PartialOverrideNode(PartialOverride)   // {{< name }}...{{/ name }}
    case PartialNode(Partial)                   // {{> name }}
    case SectionNode(Section)                   // {{# name }}...{{/ name }}, {{^ name }}...{{/ name }}
    case TextNode(String)                       // text
    case VariableNode(Variable)                 // {{ name }}, {{{ name }}}, {{& name }}
    
    
    // Define structs instead of long tuples
    
    struct Block {
        // {{$ name }}innerTemplateAST{{/ name }}
        let innerTemplateAST: TemplateAST
        let name: String
    }
    
    struct PartialOverride {
        // {{< parentPartial }}childTemplateAST{{/ parentPartial }}
        let childTemplateAST: TemplateAST
        let parentPartial: Partial
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
    
    static func block(innerTemplateAST innerTemplateAST: TemplateAST, name: String) -> TemplateASTNode {
        return .BlockNode(Block(innerTemplateAST: innerTemplateAST, name: name))
    }
    
    static func partialOverride(childTemplateAST childTemplateAST: TemplateAST, parentTemplateAST: TemplateAST, parentPartialName: String? = nil) -> TemplateASTNode {
        return .PartialOverrideNode(PartialOverride(childTemplateAST: childTemplateAST, parentPartial: Partial(templateAST: parentTemplateAST, name: parentPartialName)))
    }
    
    static func partial(templateAST templateAST: TemplateAST, name: String?) -> TemplateASTNode {
        return .PartialNode(Partial(templateAST: templateAST, name: name))
    }
    
    static func section(templateAST templateAST: TemplateAST, expression: Expression, inverted: Bool, openingToken: TemplateToken, innerTemplateString: String) -> TemplateASTNode {
        let tag = SectionTag(innerTemplateAST: templateAST, openingToken: openingToken, innerTemplateString: innerTemplateString)
        return .SectionNode(Section(tag: tag, expression: expression, inverted: inverted))
    }
    
    static func text(text text: String) -> TemplateASTNode {
        return .TextNode(text)
    }
    
    static func variable(expression expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) -> TemplateASTNode {
        let tag = VariableTag(contentType: contentType, token: token)
        return .VariableNode(Variable(tag: tag, expression: expression, escapesHTML: escapesHTML))
    }
}
