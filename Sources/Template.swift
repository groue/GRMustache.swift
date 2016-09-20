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
Template instances render Mustache templates.
*/
final public class Template {
    
    // =========================================================================
    // MARK: - Loading templates
    
    /**
    Parses a template string, and returns a template.
    
    - parameter string: The template string.
    - parameter error:  If there is an error loading or parsing template and
                        partials, throws an error that describes the problem.
    - returns: A new Template.
    */
    public convenience init(string: String) throws {
        let repository = TemplateRepository()
        let templateAST = try repository.templateAST(string: string)
        self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
    }
    
    /**
    Parses a template file, and returns a template.
    
    Eventual partial tags in the template refer to sibling template files using
    the same extension.
    
        // `{{>partial}}` in `/path/to/template.txt` loads `/path/to/partial.txt`:
        let template = try! Template(path: "/path/to/template.txt")
    
    - parameter path:     The path to the template file.
    - parameter encoding: The encoding of the template file.
    - parameter error:    If there is an error loading or parsing template and
                          partials, throws an error that describes the problem.
    - returns: A new Template.
    */
    public convenience init(path: String, encoding: String.Encoding = String.Encoding.utf8) throws {
        let nsPath = path as NSString
        let directoryPath = nsPath.deletingLastPathComponent
        let templateExtension = nsPath.pathExtension
        let templateName = (nsPath.lastPathComponent as NSString).deletingPathExtension
        let repository = TemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding)
        let templateAST = try repository.templateAST(named: templateName)
        self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
    }
    
    /**
    Parses a template file, and returns a template.
    
    Eventual partial tags in the template refer to sibling templates using
    the same extension.
    
        // `{{>partial}}` in `file://path/to/template.txt` loads `file://path/to/partial.txt`:
        let template = try! Template(URL: "file://path/to/template.txt")
    
    - parameter URL:      The URL of the template.
    - parameter encoding: The encoding of the template resource.
    - parameter error:    If there is an error loading or parsing template and
                          partials, throws an error that describes the problem.
    - returns: A new Template.
    */
    public convenience init(URL: Foundation.URL, encoding: String.Encoding = String.Encoding.utf8) throws {
        let baseURL = URL.deletingLastPathComponent()
        let templateExtension = URL.pathExtension
        let templateName = (URL.lastPathComponent as NSString).deletingPathExtension
        let repository = TemplateRepository(baseURL: baseURL, templateExtension: templateExtension, encoding: encoding)
        let templateAST = try repository.templateAST(named: templateName)
        self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
    }
    
    /**
    Parses a template resource identified by the specified name and file
    extension, and returns a template.
    
    Eventual partial tags in the template refer to template resources using
    the same extension.
    
        // `{{>partial}}` in `template.mustache` loads resource `partial.mustache`:
        let template = try! Template(named: "template")
    
    - parameter name:              The name of a bundle resource.
    - parameter bundle:            The bundle where to look for the template
                                   resource. If nil, the main bundle is used.
    - parameter templateExtension: If extension is an empty string or nil, the
                                   extension is assumed not to exist and the
                                   template file should exactly matches name.
    - parameter encoding:          The encoding of template resource.
    - parameter error:             If there is an error loading or parsing
                                   template and partials, throws an error that
                                   describes the problem.
    - returns: A new Template.
    */
    public convenience init(named name: String, bundle: Bundle? = nil, templateExtension: String? = "mustache", encoding: String.Encoding = String.Encoding.utf8) throws {
        let repository = TemplateRepository(bundle: bundle, templateExtension: templateExtension, encoding: encoding)
        let templateAST = try repository.templateAST(named: name)
        self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
    }
    
    
    // =========================================================================
    // MARK: - Rendering Templates
    
    /**
    Renders a template with a context stack initialized with the provided box
    on top of the templates's base context.
    
    - parameter box:   A boxed value used for evaluating Mustache tags.
    - parameter error: If there is an error rendering the tag, throws an error
                       that describes the problem.
    - returns: The rendered string.
    */
    public func render(_ box: MustacheBox = Box()) throws -> String {
        let rendering = try render(baseContext.extendedContext(box))
        return rendering.string
    }
    
    /**
    Returns the rendering of the receiver, evaluating mustache tags from values
    stored in the given context stack.
    
    This method does not return a String, but a Rendering value that wraps both
    the rendered string and its content type (HTML or Text). It is intended to
    be used when you perform custom rendering in a `RenderFunction`.
    
    - parameter context: A context stack
    - parameter error:   If there is an error rendering the tag, throws an
                         error that describes the problem.
    - returns: The template rendering.
    
    See also:
    
    - RenderFunction
    - Template.contentType
    */
    public func render(_ context: Context) throws -> Rendering {
        let renderingEngine = RenderingEngine(templateAST: templateAST, context: context)
        return try renderingEngine.render()
    }
    
    /**
    The content type of the template and of its renderings.
    
    See `Configuration.contentType` for a full discussion of the content type of
    templates.
    */
    public var contentType: ContentType {
        return templateAST.contentType
    }
    
    
    // =========================================================================
    // MARK: - Configuring Templates
    
    /**
    The template's base context: all renderings start from this context.
    
    Its default value comes from the configuration of the template
    repository this template comes from.
    
    You can set the base context to some custom context, or extend it with the
    `extendBaseContext` and `registerInBaseContext` methods.
    
        // Renders "bar"
        let template = try! Template(string: "{{foo}}")
        template.baseContext = Context(Box(["foo": "bar"]))
        try! template.render()
    
    See also:
    
    - extendBaseContext
    - registerInBaseContext
    */
    public var baseContext: Context
    
    /**
    Extends the base context with the provided boxed value. All renderings will
    start from this extended context.
    
        // Renders "bar"
        let template = try! Template(string: "{{foo}}")
        template.extendBaseContext(Box(["foo": "bar"]))
        try! template.render()
    
    See also:
    
    - baseContext
    - registerInBaseContext
    - Context.extendedContext
    */
    public func extendBaseContext(_ box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
    
    /**
    Registers a key in the base context. All renderings will be able to access
    the provided box through this key.
    
    Registered keys are looked up first when evaluating Mustache tags.
    
        // Renders "bar"
        let template = try! Template(string: "{{foo}}")
        template.registerInBaseContext("foo", Box("bar"))
        try! template.render()

        // Renders "bar" again, because the registered key "foo" has priority.
        try! template.render(Box(["foo": "qux"]))
    
    See also:
    
    - baseContext
    - extendBaseContext
    - Context.contextWithRegisteredKey
    */
    public func registerInBaseContext(_ key: String, _ box: MustacheBox) {
        baseContext = baseContext.contextWithRegisteredKey(key, box: box)
    }
    
    
    // =========================================================================
    // MARK: - Accessing Sibling Templates
    
    /**
    The template repository that issued the receiver.
    
    All templates belong a template repository:
    
    - Templates returned by `init(string:)` have a template
      repository that can not load any template or partial by name.
    
    - Templates returned by `init(path:encoding:)` have a template
      repository that loads templates and partials stored in the directory of
      the receiver, with the same file extension.
    
    - Templates returned by `init(URL:encoding:)` have a template
      repository that loads templates and partials stored in the directory of
      the receiver, with the same file extension.
    
    - Templates returned by `init(named:bundle:templateExtension:encoding:)`
      have a template repository that loads templates and partials stored as
      resources in the specified bundle.
    
    - Templates returned by `TemplateRepository.template(named:)` and
      `TemplateRepository.template(string:)` belong to the invoked
      repository.
    
    See also:
    
    - TemplateRepository
    - init(string:)
    - init(path:)
    - init(URL:)
    - init(named:bundle:templateExtension:encoding:)
    */
    public let repository: TemplateRepository
    
    
    // =========================================================================
    // MARK: - Not public
    
    let templateAST: TemplateAST
    
    init(repository: TemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.repository = repository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
}


// =========================================================================
// MARK: - MustacheBoxable

extension Template : MustacheBoxable {

    /**
    `Template` adopts the `MustacheBoxable` protocol so that it can feed
    Mustache templates.
    
    You should not directly call the `mustacheBox` property. Always use the
    `Box()` function instead:
    
        template.mustacheBox   // Valid, but discouraged
        Box(template)          // Preferred

    
    A template renders just like a partial tag:
    
    - `{{template}}` renders like an embedded partial tag `{{>partial}}` that
      would refer to the same template.
    
    - `{{#template}}...{{/template}}` renders like a partial override tag
      `{{<partial}}...{{/partial}}` that would refer to the same template.
    
    The difference is that `{{>partial}}` is a hard-coded template name, when
    `{{template}}` is a template that you can choose at runtime.
    
    
    For example:
    
        let template = try! Template(string: "<a href='{{url}}'>{{firstName}} {{lastName}}</a>")
        let data = [
            "firstName": Box("Salvador"),
            "lastName": Box("Dali"),
            "url": Box("/people/123"),
            "template": Box(template)
        ]
    
        // <a href='/people/123'>Salvador Dali</a>
        try! Template(string: "{{template}}").render(Box(data))
    
    Note that templates whose contentType is Text are HTML-escaped when they are
    included in an HTML template.
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            render: { (info) in
                switch info.tag {
                case let sectionTag as SectionTag:
                    // {{# template }}...{{/ template }} behaves just like {{< partial }}...{{/ partial }}
                    //
                    // Let's render the template, overriding blocks with the content
                    // of the section.
                    //
                    // Overriding requires an PartialOverrideNode:
                    let partialOverrideNode = TemplateASTNode.partialOverride(
                        childTemplateAST: sectionTag.innerTemplateAST,
                        parentTemplateAST: self.templateAST)
                    
                    // Only RenderingEngine knows how to render PartialOverrideNode.
                    // So wrap the node into a TemplateAST, and render.
                    let renderingEngine = RenderingEngine(
                        templateAST: TemplateAST(nodes: [partialOverrideNode], contentType: self.templateAST.contentType),
                        context: info.context)
                    return try renderingEngine.render()
                default:
                    // Assume Variable tag
                    //
                    // {{ template }} behaves just like {{> partial }}
                    //
                    // Let's simply render the template:
                    return try self.render(info.context)
                }
        })
    }
}
