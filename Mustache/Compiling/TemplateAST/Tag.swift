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
The type of a tag, variable or section. See the documentation of `Tag` for more
information.
*/
public enum TagType {
    
    /// The type of tags such as `{{name}}` and `{{{body}}}`.
    case Variable
    
    /// The type of section tags such as `{{#user}}...{{/user}}`.
    case Section
}

/**
Tag instances represent Mustache tags that render values:

- variable tags: `{{name}}` and `{{{body}}}`
- section tags: `{{#user}}...{{/user}}`

You may meet the Tag class when you implement your own `RenderFunction`,
`WillRenderFunction` or `DidRenderFunction`, or filters that perform custom
rendering (see `FilterFunction`).

:see: RenderFunction
:see: WillRenderFunction
:see: DidRenderFunction
*/
public class Tag: Printable {
    
    /**
    The type of the tag: variable or section:
    
        let render: RenderFunction = { (info: RenderingInfo, _) in
            switch info.tag.type {
            case .Variable:
                return Rendering("variable")
            case .Section:
                return Rendering("section")
            }
        }

        let template = Template(string: "{{object}}, {{#object}}...{{/object}}")!

        // Renders "variable, section"
        template.render(Box(["object": Box(render)]))!
    */
    public let type: TagType
    
    /**
    The literal and unprocessed inner content of the tag.
    
    A section tag such as `{{# person }}Hello {{ name }}!{{/ person }}` returns
    "Hello {{ name }}!".
    
    Variable tags such as `{{ name }}` have no inner content: their inner
    template string is the empty string.
    
        // {{# pluralize(count) }}...{{/ }} renders the plural form of the section
        // content if the `count` argument is greater than 1.
        let pluralize = Filter { (count: Int, info: RenderingInfo, _) in

            // Pluralize the inner content of the section tag:
            var string = info.tag.innerTemplateString
            if count > 1 {
                string += "s"  // naive
            }

            return Rendering(string)
        }

        let template = Template(string: "I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.")!
        template.registerInBaseContext("pluralize", Box(pluralize))

        // Renders "I have 3 cats."
        let data = ["cats": ["Kitty", "Pussy", "Melba"]]
        template.render(Box(data))!
    */
    public let innerTemplateString: String
    
    /// The delimiters of the tag.
    public let tagDelimiterPair: TagDelimiterPair
    
    /**
    Returns the rendering of the tag's inner content. All inner tags are
    evaluated with the provided context.
    
    This method does not return a String, but a Rendering value that wraps both
    the rendered string and its content type (HTML or Text).
    
    The contentType is HTML, unless specified otherwise by `Configuration`, or
    a `{{% CONTENT_TYPE:TEXT }}` pragma tag.
    
        // The strong RenderFunction below wraps a section in a <strong> HTML tag.
        let strong: RenderFunction = { (info: RenderingInfo, _) -> Rendering? in
            let rendering = info.tag.render(info.context)
            return Rendering("<strong>\(rendering!.string)</strong>", .HTML)
        }

        let template = Template(string: "{{#strong}}Hello {{name}}{{/strong}}")!
        template.registerInBaseContext("strong", Box(strong))

        // Renders "<strong>Hello Arthur</strong>"
        template.render(Box(["name": Box("Arthur")]))!
    
    :param: context The context stack for evaluating mustache tags
    :param: error   If there is a problem rendering the tag, upon return
                    contains an NSError object that describes the problem.
    
    :returns: The rendering of the tag
    
    */
    public func render(context: Context, error: NSErrorPointer = nil) -> Rendering? {
        fatalError("Subclass must override")
    }
    
    /// A human-readable description of the tag.
    public var description: String {
        fatalError("Subclass must override")
    }
    
    
    // =========================================================================
    // MARK: - Not public
    
    init(type: TagType, innerTemplateString: String, tagDelimiterPair: TagDelimiterPair) {
        self.type = type
        self.innerTemplateString = innerTemplateString
        self.tagDelimiterPair = tagDelimiterPair
    }
}
