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

/**
The protocol for Template AST nodes.

When parsing a Mustache template, the compiler builds an abstract tree of
objects representing raw text and various mustache tags.

This abstract tree is made of objects conforming to the TemplateASTNode
protocol.

For example, the template string "hello {{name}}!" would give three AST nodes:

- a TextNode that renders "hello ".
- a VariableTag that renders the value of the `name` expression.
- a TextNode that renders "!".
*/
protocol TemplateASTNode: class {   // class so that we can use the !== operator (see Context.swift)
    
    /**
    Has the visitor visit the node.
    */
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult
    
    /**
    Support for template inheritance.
    
    Returns the node that should be rendered in lieu of the node argument.
    
    All conforming classes return the node argument, but InheritableSectionNode,
    InheritedPartialNode, and PartialNode.
    */
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode
}

/**
A template AST visitor handles AST nodes.

RenderingEngine conforms to this protocol so that it can render templates.
*/
protocol TemplateASTVisitor {
    func visit(inheritedPartialNode: InheritedPartialNode) -> TemplateASTVisitResult
    func visit(inheritableSectionNode: InheritableSectionNode) -> TemplateASTVisitResult
    func visit(partialNode: PartialNode) -> TemplateASTVisitResult
    func visit(variableTag: VariableTag) -> TemplateASTVisitResult
    func visit(sectionTag: SectionTag) -> TemplateASTVisitResult
    func visit(textNode: TextNode) -> TemplateASTVisitResult
}

enum TemplateASTVisitResult {
    case Error(NSError)
    case Success
}

