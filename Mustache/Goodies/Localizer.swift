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
    
    public class Localizer : MustacheBoxable {
        public let bundle: NSBundle
        public let table: String?
        var formatArguments: [String]?
        
        public init(bundle: NSBundle?, table: String?) {
            self.bundle = bundle ?? NSBundle.mainBundle()
            self.table = table
        }
        
        private func filter(rendering: Rendering, error: NSErrorPointer) -> Rendering? {
            return Rendering(localizedStringForKey(rendering.string), rendering.contentType)
        }
        
        public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
            
            /**
            * Perform a first rendering of the section tag, that will turn variable
            * tags into a custom placeholder.
            *
            * "...{{name}}..." will get turned into "...GRMustacheLocalizerValuePlaceholder...".
            *
            * For that, we make sure we are notified of tag rendering, so that our
            * mustacheTag:willRenderObject: implementation tells the tags to render
            * GRMustacheLocalizerValuePlaceholder instead of the regular values,
            * "Arthur" or "Barbara". This behavior is trigerred by the nil value of
            * self.formatArguments.
            */
            
            // Set up first pass behavior
            formatArguments = nil
            
            // Render the localizable format, being notified of tag rendering
            let context = info.context.extendedContext(Box(self))
            var error: NSError?
            if let localizableFormatRendering = info.tag.renderInnerContent(context, error: &error) {
                
                /**
                * Perform a second rendering that will fill our formatArguments array with
                * HTML-escaped tag renderings.
                *
                * Now our mustacheTag:willRenderObject: implementation will let the regular
                * values go through normal rendering ("Arthur" or "Barbara"). Our
                * mustacheTag:didRenderObject:as: method will fill self.formatArguments.
                *
                * This behavior is not the same as the previous one, and is trigerred by
                * the non-nil value of self.formatArguments.
                */
                
                // Set up second pass behavior
                formatArguments = []
                
                // Fill formatArguments
                info.tag.renderInnerContent(context)
                
                
                /**
                * Localize the format, and render.
                */
                
                var rendering: Rendering
                if formatArguments!.isEmpty {
                    rendering = Rendering(localizedStringForKey(localizableFormatRendering.string), localizableFormatRendering.contentType)
                } else {
                    /**
                    * When rendering {{#localize}}%d {{name}}{{/localize}},
                    * The localizableFormat string we have just built is
                    * "%d GRMustacheLocalizerValuePlaceholder".
                    *
                    * In order to get an actual format string, we have to:
                    * - turn GRMustacheLocalizerValuePlaceholder into %@
                    * - escape % into %%.
                    *
                    * The format string will then be "%%d %@".
                    */
                    
                    var localizableFormat = localizableFormatRendering.string.stringByReplacingOccurrencesOfString("%", withString: "%%")
                    localizableFormat = localizableFormat.stringByReplacingOccurrencesOfString(Placeholder.string, withString: "%@")
                    let localizedFormat = localizedStringForKey(localizableFormat)
                    let localizedRendering = stringWithFormat(format: localizedFormat, argumentsArray: formatArguments!)
                    rendering = Rendering(localizedRendering, localizableFormatRendering.contentType)
                }
                
                formatArguments = nil
                return rendering
            } else {
                return nil
            }
        }
        
        public func willRender(tag: Tag, box: MustacheBox) -> MustacheBox {
            switch tag.type {
            case .Variable:
                // {{ value }}
                //
                // We behave as stated in renderForMustacheTag(tag:,info:,contentType:,error:)
                
                if formatArguments == nil {
                    return Box(Placeholder.string)
                } else {
                    return box
                }
                
            case .Section:
                // {{# value }}
                // {{^ value }}
                //
                // We do not want to mess with Mustache handling of boolean sections
                // such as {{#true}}...{{/}}.
                return box
            }
        }
        
        public func didRender(tag: Tag, box: MustacheBox, string: String?) {
            switch tag.type {
            case .Variable:
                // {{ value }}
                //
                // We behave as stated in renderForMustacheTag(tag:,info:,contentType:,error:)
                
                if formatArguments != nil {
                    if let string = string {
                        formatArguments!.append(string)
                    }
                }
                
            case .Section:
                // {{# value }}
                // {{^ value }}
                break
            }
        }
        
        
        // MARK: - MustacheBoxable
        
        public var mustacheBox: MustacheBox {
            return Box(
                value: self,
                render: render,
                filter: Filter(filter),
                willRender: willRender,
                didRender: didRender)
        }
        
        
        // MARK: - Private
        
        private func localizedStringForKey(key: String) -> String {
            return bundle.localizedStringForKey(key, value:"", table:table)
        }
        
        private func stringWithFormat(#format: String, argumentsArray args:[String]) -> String {
            switch countElements(args) {
            case 0:
                return format
            case 1:
                return String(format: format, args[0])
            case 2:
                return String(format: format, args[0], args[1])
            case 3:
                return String(format: format, args[0], args[1], args[2])
            case 4:
                return String(format: format, args[0], args[1], args[2], args[3])
            case 5:
                return String(format: format, args[0], args[1], args[2], args[3], args[4])
            case 6:
                return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5])
            case 7:
                return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
            case 8:
                return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
            case 9:
                return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
            case 10:
                return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
            default:
                fatalError("Not implemented: format with \(countElements(args)) parameters")
            }
        }
        
        struct Placeholder {
            static let string = "GRMustacheLocalizerValuePlaceholder"
        }
    }

}
