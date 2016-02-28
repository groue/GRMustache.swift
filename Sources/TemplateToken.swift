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


struct TemplateToken {
    enum `Type` {
        /// text
        case Text(text: String)
        
        /// {{ content }}
        case EscapedVariable(content: String, tagDelimiterPair: TagDelimiterPair)
        
        /// {{{ content }}}
        case UnescapedVariable(content: String, tagDelimiterPair: TagDelimiterPair)
        
        /// {{! comment }}
        case Comment
        
        /// {{# content }}
        case Section(content: String, tagDelimiterPair: TagDelimiterPair)
        
        /// {{^ content }}
        case InvertedSection(content: String, tagDelimiterPair: TagDelimiterPair)
        
        /// {{/ content }}
        case Close(content: String)
        
        /// {{> content }}
        case Partial(content: String)
        
        /// {{= ... ... =}}
        case SetDelimiters
        
        /// {{% content }}
        case Pragma(content: String)
        
        /// {{< content }}
        case PartialOverride(content: String)
        
        /// {{$ content }}
        case Block(content: String)
    }
    
    let type: Type
    let lineNumber: Int
    let templateID: TemplateID?
    let templateString: String
    let range: Range<String.Index>
    
    var templateSubstring: String { return templateString[range] }
    
    var tagDelimiterPair: TagDelimiterPair? {
        switch type {
        case .EscapedVariable(content: _, tagDelimiterPair: let tagDelimiterPair):
            return tagDelimiterPair
        case .UnescapedVariable(content: _, tagDelimiterPair: let tagDelimiterPair):
            return tagDelimiterPair
        case .Section(content: _, tagDelimiterPair: let tagDelimiterPair):
            return tagDelimiterPair
        case .InvertedSection(content: _, tagDelimiterPair: let tagDelimiterPair):
            return tagDelimiterPair
        default:
            return nil
        }
    }
    
    var locationDescription: String {
        if let templateID = templateID {
            return "line \(lineNumber) of template \(templateID)"
        } else {
            return "line \(lineNumber)"
        }
    }
}
