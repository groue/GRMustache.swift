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

extension NSFormatter: ObjCMustacheBoxable {
    
    private func filter(box: MustacheBox, error: NSErrorPointer) -> MustacheBox? {
        if let object = box.value as? NSObject {
            return Box(self.stringForObjectValue(object))
        } else {
            return Box()
        }
    }
    
    private func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            // {{ formatter }}
            // Behave as a regular object: render self's description
            return Rendering("\(self)")
        case .Section:
            // {{# formatter }}...{{/ formatter }}
            // {{^ formatter }}...{{/ formatter }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            return info.tag.render(info.context.extendedContext(Box(self)), error: error)
        }
    }
    
    private func willRender(tag: Tag, box: MustacheBox) -> MustacheBox {
        switch tag.type {
        case .Variable:
            // {{ value }}
            
            if let object = box.value as? NSObject {
                // NSFormatter documentation for stringForObjectValue: states:
                //
                // > First test the passed-in object to see if it’s of the correct
                // > class. If it isn’t, return nil; but if it is of the right class,
                // > return a properly formatted and, if necessary, localized string.
                //
                // So nil result means that object is not of the correct class. Leave
                // it untouched.
                
                if let formatted = self.stringForObjectValue(object) {
                    return Box(formatted)
                }
            }
            return box
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            return box
        }
    }
    
    
    // MARK: - ObjCMustacheBoxable
    
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(Box(
            value: self,
            render: render,
            filter: Filter(filter),
            willRender: willRender))
    }
}
