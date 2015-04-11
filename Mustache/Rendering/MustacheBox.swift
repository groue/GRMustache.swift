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
MustacheBox wraps values that feed your templates.

This type has no public initializer. To produce boxes, you use one variant of
the Box() function, or BoxAnyObject().

:see: Box()
:see: BoxAnyObject()
*/
public struct MustacheBox {
    
    // -------------------------------------------------------------------------
    // MARK: - The boxed value
    
    /**
    The boxed value.
    */
    public let value: Any?
    
    /**
    The only empty box is Box(). In particular, Box(NSNull()) is not empty.
    */
    public let isEmpty: Bool
    
    /**
    The boolean value of the box.
    
    It tells whether the Box should trigger or prevent the rendering of regular
    {{#section}}...{{/}} and inverted {{^section}}...{{/}}.
    */
    public let boolValue: Bool
    
    /**
    If the boxed value is a Swift numerical value, a Bool, or an NSNumber,
    returns this value as an Int.
    */
    public var intValue: Int? {
        return converter?.intValue?()
    }
    
    /**
    If the boxed value is a Swift numerical value, a Bool, or an NSNumber,
    returns this value as a UInt.
    */
    public var uintValue: UInt? {
        return converter?.uintValue?()
    }
    
    /**
    If the boxed value is a Swift numerical value, a Bool, or an NSNumber,
    returns this value as a Double.
    */
    public var doubleValue: Double? {
        return converter?.doubleValue?()
    }
    
    /**
    If boxed value can be iterated (Swift collection, NSArray, NSSet, etc.),
    returns a [MustacheBox].
    */
    public var arrayValue: [MustacheBox]? {
        return converter?.arrayValue?()
    }
    
    /**
    If boxed value is a dictionary (Swift dictionary, NSDictionary, etc.),
    returns a [String: MustacheBox] dictionary.
    */
    public var dictionaryValue: [String: MustacheBox]? {
        return converter?.dictionaryValue?()
    }
    
    
    // -------------------------------------------------------------------------
    // MARK: - Rendering a Box
    
    /**
    TODO
    */
    public private(set) var render: RenderFunction
    
    
    // -------------------------------------------------------------------------
    // MARK - Key extraction
    
    /**
    Extract a key out of a box.
    
    ::
    
      let box = Box("Arthur")
      box["length"].intValue!    // 6
    */
    public subscript (key: String) -> MustacheBox {
        return keyedSubscript?(key: key) ?? Box()
    }
    
    
    // -------------------------------------------------------------------------
    // MARK: - Internal
    
    let keyedSubscript: KeyedSubscriptFunction?
    let filter: FilterFunction?
    let willRender: WillRenderFunction?
    let didRender: DidRenderFunction?
    let converter: Converter?
    
    init(
        boolValue: Bool? = nil,
        value: Any? = nil,
        converter: Converter? = nil,
        keyedSubscript: KeyedSubscriptFunction? = nil,
        filter: FilterFunction? = nil,
        render: RenderFunction? = nil,
        willRender: WillRenderFunction? = nil,
        didRender: DidRenderFunction? = nil)
    {
        let empty = (value == nil) && (keyedSubscript == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
        self.converter = converter
        self.boolValue = boolValue ?? !empty
        self.keyedSubscript = keyedSubscript
        self.filter = filter
        self.willRender = willRender
        self.didRender = didRender
        if let render = render {
            self.render = render
        } else {
            // The default render function: it renders {{variable}} tags as the
            // boxed value, and {{#section}}...{{/}} tags by adding the box to
            // the context stack.
            //
            // We have to set self.render twice in order to avoid the compiler
            // error: "variable 'self.render' captured by a closure before being
            // initialized"
            self.render = { (_, _) in return nil }
            self.render = { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ box }}
                    if let value = value {
                        return Rendering("\(value)")
                    } else {
                        return Rendering("")
                    }
                case .Section:
                    // {{# box }}...{{/ box }}
                    let context = info.context.extendedContext(self)
                    return info.tag.renderInnerContent(context, error: error)
                }
            }
        }
    }
    
    // Converter wraps all the conversion closures that help MustacheBox expose
    // its raw value (typed Any) as useful types such as Int, Double, etc.
    //
    // Without those conversions, it would be very difficult for the library
    // user to write code that processes, for example, a boxed number: she
    // would have to try casting the boxed value to Int, UInt, Double, NSNumber
    // etc. until she finds its actual type.
    struct Converter {
        let intValue: (() -> Int?)?
        let uintValue: (() -> UInt?)?
        let doubleValue: (() -> Double?)?
        let arrayValue: (() -> [MustacheBox]?)?
        let dictionaryValue: (() -> [String: MustacheBox]?)?
        
        init(
            intValue: (() -> Int?)? = nil,
            uintValue: (() -> UInt?)? = nil,
            doubleValue: (() -> Double?)? = nil,
            arrayValue: (() -> [MustacheBox]?)? = nil,
            dictionaryValue: (() -> [String: MustacheBox]?)? = nil)
        {
            self.intValue = intValue
            self.uintValue = uintValue
            self.doubleValue = doubleValue
            self.arrayValue = arrayValue
            self.dictionaryValue = dictionaryValue
        }
        
        
        // IMPLEMENTATION NOTE
        //
        // It looks like Swift does not provide any way to perform a safe
        // conversion between its numeric types.
        //
        // For example, there exists a UInt(Int) initializer, but it fails
        // with EXC_BAD_INSTRUCTION when given a negative Int.
        //
        // So we implement below our own numeric conversion functions.
        
        static func uint(x: Int) -> UInt? {
            if x >= 0 {
                return UInt(x)
            } else {
                return nil
            }
        }
        
        static func uint(x: Double) -> UInt? {
            if x == Double(UInt.max) {
                return UInt.max
            } else if x >= 0 && x < Double(UInt.max) {
                return UInt(x)
            } else {
                return nil
            }
        }
        
        static func int(x: UInt) -> Int? {
            if x <= UInt(Int.max) {
                return Int(x)
            } else {
                return nil
            }
        }
        
        static func int(x: Double) -> Int? {
            if x == Double(Int.max) {
                return Int.max
            } else if x >= Double(Int.min) && x < Double(Int.max) {
                return Int(x)
            } else {
                return nil
            }
        }

    }

    // Hackish helper function which helps us boxing NSArray.
    func boxWithValue(value: Any?) -> MustacheBox {
        return MustacheBox(
            boolValue: self.boolValue,
            value: value,
            converter: self.converter,
            keyedSubscript: self.keyedSubscript,
            filter: self.filter,
            render: self.render,
            willRender: self.willRender,
            didRender: self.didRender)
    }
}

extension MustacheBox : DebugPrintable {
    
    public var debugDescription: String {
        if let value = value {
            return "MustacheBox(\(value))"  // remove "Optional" from the output
        } else {
            return "MustacheBox(nil)"
        }
    }
}
