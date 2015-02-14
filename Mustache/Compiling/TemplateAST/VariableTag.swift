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

class VariableTag: Tag, TemplateASTNode {
    let token: TemplateToken
    let contentType: ContentType
    let escapesHTML: Bool
    
    init(expression: Expression, contentType: ContentType, escapesHTML: Bool, token: TemplateToken) {
        self.escapesHTML = escapesHTML
        self.contentType = contentType
        self.token = token
        super.init(type: .Variable, innerTemplateString: "", inverted: false, expression: expression)
    }
    
    override var description: String {
        if let templateID = token.templateID {
            return "\(token.templateSubstring) at line \(token.lineNumber) of template \(templateID)"
        } else {
            return "\(token.templateSubstring) at line \(token.lineNumber)"
        }
    }
    
    override func renderInnerContent(context: Context, error: NSErrorPointer) -> Rendering? {
        return Rendering("", contentType)
    }
    
    func acceptTemplateASTVisitor(visitor: TemplateASTVisitor) -> TemplateASTVisitResult {
        return visitor.visit(self)
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
}