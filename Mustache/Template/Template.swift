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
    
    :param: string The template string
    :param: error  If there is an error loading or parsing template and
                   partials, upon return contains an NSError object that
                   describes the problem.
    
    :returns: The created template
    */
    public convenience init?(string: String, error: NSErrorPointer = nil) {
        let repository = TemplateRepository()
        
        if let templateAST = repository.templateAST(string: string, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template file, and returns a template.
    
    Eventual partial tags in the template refer to sibling template files using
    the same extension.
    
        // `{{>partial}}` in `/path/to/template.txt` loads `/path/to/partial.txt`:
        let template = Template(path: "/path/to/template.txt")!
    
    :param: path     The path of the template.
    :param: encoding The encoding of the template file.
    :param: error    If there is an error loading or parsing template and
                     partials, upon return contains an NSError object that
                     describes the problem.
    
    :returns: The created template
    */
    public convenience init?(path: String, encoding: NSStringEncoding = NSUTF8StringEncoding, error: NSErrorPointer = nil) {
        let directoryPath = path.stringByDeletingLastPathComponent
        let templateExtension = path.pathExtension
        let templateName = path.lastPathComponent.stringByDeletingPathExtension
        let repository = TemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding)
        
        if let templateAST = repository.templateAST(named: templateName, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template file, and returns a template.
    
    Eventual partial tags in the template refer to sibling templates using
    the same extension.
    
        // `{{>partial}}` in `file://path/to/template.txt` loads `file://path/to/partial.txt`:
        let template = Template(URL: "file://path/to/template.txt")!
    
    :param: URL      The URL of the template.
    :param: encoding The encoding of template file.
    :param: error    If there is an error loading or parsing template and
                     partials, upon return contains an NSError object that
                     describes the problem.
    
    :returns: The created template
    */
    public convenience init?(URL: NSURL, encoding: NSStringEncoding = NSUTF8StringEncoding, error: NSErrorPointer = nil) {
        let baseURL = URL.URLByDeletingLastPathComponent!
        let templateExtension = URL.pathExtension
        let templateName = URL.lastPathComponent!.stringByDeletingPathExtension
        let repository = TemplateRepository(baseURL: baseURL, templateExtension: templateExtension, encoding: encoding)
        
        if let templateAST = repository.templateAST(named: templateName, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template resource identified by the specified name and file
    extension, and returns a template.
    
    Eventual partial tags in the template refer to template resources using
    the same extension.
    
        // `{{>partial}}` in `template.mustache` loads resource `partial.mustache`:
        let template = Template(named: "template")!
    
    :param: name               The name of a bundle resource.
    :param: bundle             The bundle where to look for the template
                               resource. If nil, the main bundle is used.
    :param: templateExtension  If extension is an empty string or nil, the
                               extension is assumed not to exist and the
                               template file should exactly matches name.
    :param: encoding           The encoding of template resource.
    :param: error              If there is an error loading or parsing template
                               and partials, upon return contains an NSError
                               object that describes the problem.
    
    :returns: The created template
    */
    public convenience init?(named name: String, bundle: NSBundle? = nil, templateExtension: String? = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding, error: NSErrorPointer = nil) {
        let repository = TemplateRepository(bundle: bundle, templateExtension: templateExtension, encoding: encoding)
        
        if let templateAST = repository.templateAST(named: name, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    
    // =========================================================================
    // MARK: - Rendering Templates
    
    /**
    Renders a template with a context stack initialized with the provided box
    on top of the templates's base context.
    
    :param: box   A boxed value used for evaluating Mustache tags
    :param: error If there is an error rendering the tag, upon return contains
                  an NSError object that describes the problem.
    
    :returns: The rendered string
    */
    public func render(_ box: MustacheBox = Box(), error: NSErrorPointer = nil) -> String? {
        if let rendering = render(baseContext.extendedContext(box), error: error) {
            return rendering.string
        } else {
            return nil
        }
    }
    
    /**
    Returns the rendering of the receiver, evaluating mustache tags from values
    stored in the given context stack.
    
    This method does not return a String, but a Rendering value that wraps both
    the rendered string and its content type (HTML or Text). It is intended to
    be used when you perform custom rendering in a `RenderFunction`.
    
    :param: context A context stack
    :param: error   If there is an error rendering the tag, upon return contains
                    an NSError object that describes the problem.
    
    :returns: The template rendering
    
    :see: RenderFunction
    */
    public func render(context: Context, error: NSErrorPointer = nil) -> Rendering? {
        let renderingEngine = RenderingEngine(templateAST: templateAST, context: context)
        return renderingEngine.render(error: error)
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
        let template = Template(string: "{{foo}}")!
        template.baseContext = Context(Box(["foo": "bar"]))
        template.render()!
    
    :see: extendBaseContext
    :see: registerInBaseContext
    */
    public var baseContext: Context
    
    /**
    Extends the base context with the provided boxed value. All renderings will
    start from this extended context.
    
        // Renders "bar"
        let template = Template(string: "{{foo}}")!
        template.extendBaseContext(Box(["foo": "bar"]))
        template.render()!
    
    :see: baseContext
    :see: registerInBaseContext
    :see: Context.extendedContext
    */
    public func extendBaseContext(box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
    
    /**
    Registers a key in the base context. All renderings will be able to access
    the provided box through this key.
    
    Registered keys are looked up first when evaluating Mustache tags.
    
        // Renders "bar"
        let template = Template(string: "{{foo}}")!
        template.registerInBaseContext("foo", Box("bar"))
        template.render()!

        // Renders "bar" again, because the registered key "foo" has priority.
        template.render(Box(["foo": "qux"]))!
    
    :see: baseContext
    :see: extendBaseContext
    :see: Context.contextWithRegisteredKey
    */
    public func registerInBaseContext(key: String, _ box: MustacheBox) {
        baseContext = baseContext.contextWithRegisteredKey(key, box: box)
    }
    
    
    // =========================================================================
    // MARK: - Accessing Sibling Templates
    
    /**
    The template repository that issued the receiver.
    
    All templates belong a template repository:
    
    - Templates returned by ``init?(string:error:)`` have a template
      repository that can not load any template or partial by name.
    
    - Templates returned by ``init?(path:encoding:error:)`` have a template
      repository that loads templates and partials stored in the directory of
      the receiver, with the same file extension.
    
    - Templates returned by ``init?(URL:encoding:error:)`` have a template
      repository that loads templates and partials stored in the directory of
      the receiver, with the same file extension.
    
    - Templates returned by ``init?(named:bundle:templateExtension:encoding:error:)``
      have a template repository that loads templates and partials stored as
      resources in the specified bundle.
    
    - Templates returned by ``TemplateRepository.template(named:error:)`` and
      `TemplateRepository.template(string:error:)` belong to the invoked
      repository.
    
    :see: TemplateRepository
    :see: init(string:error:)
    :see: init(path:error:)
    :see: init(URL:error:)
    :see: init(named:bundle:templateExtension:encoding:error:)
    */
    public let repository: TemplateRepository
    
    
    // =========================================================================
    // MARK: - Accessing Sibling Templates
    
    /**
    The content type of the template.
    
    See `Configuration.contentType` for a full discussion of the content type of
    templates.
    */
    public var contentType: ContentType {
        return templateAST.contentType
    }
    
    
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
    `Template` conforms to the `MustacheBoxable` protocol so that it can feed
    other Mustache templates. A template renders just like a partial tag:
    
    - `{{partial}}` renders like an embedded partial tag `{{>name}}` that would
      refer to the same template.
    
    - `{{#partial}}...{{/partial}}` renders like an inherited partial tag
      `{{<name}}...{{/name}}` that would refer to the same template.
    
    The difference is that `name` is a hard-coded template name, when
    `partial` is a template that is chosen at runtime.
    
    For example:
    
        let partial = Template(string: "<a href='{{url}}'>{{firstName}} {{lastName}}</a>")!
        let data = [
            "firstName": Box("Salvador"),
            "lastName": Box("Dali"),
            "url": Box("/people/123"),
            "partial": Box(partial)
        ]
    
        // <a href='/people/123'>Salvador Dali</a>
        let template = Template(string: "{{partial}}")!
        template.render(Box(data))!
    
    Note that templates whose contentType is Text are HTML-escaped when they are
    included in an HTML template.
    */
    public var mustacheBox: MustacheBox {
        return Box(value: self, render: { (var info, error) in
            switch info.tag.type {
            case .Variable:
                // {{ template }} behaves just like {{> partial }}
                //
                // Let's simply render the template:
                return self.render(info.context, error: error)
                
            case .Section:
                // {{# template }}...{{/ template }} behaves just like {{< partial }}...{{/ partial }}
                //
                // Let's render the template, overriding inheritable sections
                // with the content of the rendered section.
                //
                // Inheriting requires an InheritedPartialNode:
                let inheritablePartialNode = TemplateASTNode.inheritedPartial(
                    overridingTemplateAST: (info.tag as! SectionTag).innerTemplateAST,
                    inheritedTemplateAST: self.templateAST)
                
                // Only RenderingEngine knows how to render InheritedPartialNode.
                // So wrap the node into a TemplateAST, and render.
                let renderingEngine = RenderingEngine(
                    templateAST: TemplateAST(nodes: [inheritablePartialNode], contentType: self.templateAST.contentType),
                    context: info.context)
                return renderingEngine.render(error: error)
            }
        })
    }
}
