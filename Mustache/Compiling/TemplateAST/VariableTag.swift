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
VariableTag represents a variable tag such as {{name}} or {{{name}}}.
*/
class VariableTag: Tag {
    let token: TemplateToken
    let contentType: ContentType
    
    init(contentType: ContentType, token: TemplateToken) {
        self.contentType = contentType
        self.token = token
        super.init(type: .Variable, innerTemplateString: "", tagDelimiterPair: token.tagDelimiterPair!)
    }
    
    /**
    VariableTag is an internal class, but it inherits the Printable protocol
    from its public superclass Tag. Return a nice user-friendly description:
    */
    override var description: String {
        if let templateID = token.templateID {
            return "\(token.templateSubstring) at line \(token.lineNumber) of template \(templateID)"
        } else {
            return "\(token.templateSubstring) at line \(token.lineNumber)"
        }
    }
    
    /**
    Inherited from the public super class Tag. Variable have no inner content.
    */
    override func render(context: Context, error: NSErrorPointer) -> Rendering? {
        return Rendering("", contentType)
    }
}