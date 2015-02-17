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


/**
A PartialNode is an AST node that represents partial tags such as {{>partial}}.
*/
class PartialNode: TemplateASTNode {
    let templateAST: TemplateAST

    // partialName is a vestigial property not used in GRMustache.swift.
    //
    // Objective-C GRMustache has a GRMustacheTemplateGenerator class which
    // turns AST into template strings, and uses this name to output partial
    // tags {{> partialName }}.
    let partialName: String
    
    init(partialName: String, templateAST: TemplateAST) {
        self.partialName = partialName
        self.templateAST = templateAST
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult {
        return visitor.visit(self)
    }

    func resolveTemplateASTNode(var node: TemplateASTNode) -> TemplateASTNode {
        for innerNode in templateAST.nodes {
            node = innerNode.resolveTemplateASTNode(node)
        }
        return node
    }
}