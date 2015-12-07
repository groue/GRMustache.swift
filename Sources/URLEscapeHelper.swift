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

final class URLEscapeHelper : MustacheBoxable {
    
    var mustacheBox: MustacheBox {
        // Return a multi-facetted box, because URLEscape interacts in
        // various ways with Mustache rendering.
        return MustacheBox(
            // It has a value:
            value: self,
            
            // URLEscape can be used as a filter: {{ URLEscape(x) }}:
            filter: Filter(filter),
            
            // URLEscape escapes all variable tags: {{# URLEscape }}...{{ x }}...{{/ URLEscape }}
            willRender: willRender)
    }
    
    // This function is used for evaluating `URLEscape(x)` expressions.
    private func filter(rendering: Rendering) throws -> Rendering {
        return Rendering(URLEscapeHelper.escapeURL(rendering.string), rendering.contentType)
    }
    
    // A WillRenderFunction: this function lets URLEscape change values that
    // are about to be rendered to their escaped counterpart.
    //
    // It is activated as soon as the formatter enters the context stack, when
    // used in a section {{# URLEscape }}...{{/ URLEscape }}.
    private func willRender(tag: Tag, box: MustacheBox) -> MustacheBox {
        switch tag.type {
        case .Variable:
            // We don't know if the box contains a String, so let's escape its
            // rendering.
            return Box({ (info: RenderingInfo) -> Rendering in
                let rendering = try box.render(info: info)
                return try self.filter(rendering)

            })
        case .Section:
            return box
        }
    }
    
    private class func escapeURL(string: String) -> String {
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        s.removeCharactersInString("?&=")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(s) ?? ""
    }
}
