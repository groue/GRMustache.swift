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
A SectionTag represents a regular or inverted section tag such as
{{#section}}...{{/section}} or {{^section}}...{{/section}}.
*/
class SectionTag: Tag {
    let openingToken: TemplateToken
    let innerTemplateAST: TemplateAST
    
    init(innerTemplateAST: TemplateAST, openingToken: TemplateToken, innerTemplateString: String) {
        self.innerTemplateAST = innerTemplateAST
        self.openingToken = openingToken
        super.init(type: .Section, innerTemplateString: innerTemplateString, tagDelimiterPair: openingToken.tagDelimiterPair!)
    }
    
    /**
    SectionTag is an internal class, but it inherits the Printable protocol from
    its public superclass Tag. Return a nice user-friendly description:
    */
    override var description: String {
        if let templateID = openingToken.templateID {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber) of template \(templateID)"
        } else {
            return "\(openingToken.templateSubstring) at line \(openingToken.lineNumber)"
        }
    }
    
    /**
    Inherited from the public super class Tag
    */
    override func render(context: Context, error: NSErrorPointer) -> Rendering? {
        let renderingEngine = RenderingEngine(templateAST: innerTemplateAST, context: context)
        return renderingEngine.render(error: error)
    }
}