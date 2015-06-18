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


extension StandardLibrary {
    public class Logger : MustacheBoxable {
        public typealias LogFunction = (String) -> Void
        private let log: LogFunction
        private var indentationLevel: Int = 0
        
        public init(log: LogFunction? = nil) {
            if let log = log {
                self.log = log
            } else {
                self.log = { NSLog($0) }
            }
        }
        
        public var mustacheBox: MustacheBox {
            return Box(
                willRender: { (tag, box) in
                    if tag.type == .Section {
                        let prefix = String(count: self.indentationLevel * 2, repeatedValue: " " as Character)
                        self.log("\(prefix)\(tag) will render \(self.boxDescription(box))")
                        self.indentationLevel++
                    }
                    return box
                },
                didRender: { (tag, box, string) in
                    if tag.type == .Section {
                        self.indentationLevel--
                    }
                    if let string = string {
                        let prefix = String(count: self.indentationLevel * 2, repeatedValue: " " as Character)
                        self.log("\(prefix)\(tag) did render \(self.boxDescription(box)) as \"\(string)\"")
                    }
                }
            )
        }
        
        private func boxDescription(box: MustacheBox) -> String {
            if box.isEmpty {
                return "(missing)"
            } else if let array = box.arrayValue {
                let x = ",".join(array.map { self.boxDescription($0) })
                return "[\(x)]"
            } else if let dictionary = box.dictionaryValue {
                if dictionary.isEmpty {
                    return "[:]"
                } else {
                    let x = ",".join(dictionary.map { (key, box) in "\(key):\(self.boxDescription(box))" })
                    return "[\(x)]"
                }
            } else if let string = box.value as? String {
                return "\"\(string)\""
            } else if let value = box.value {
                return "\(value)"
            } else {
                return "(unknown)"
            }
        }
    }
}
