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
The Template class provides Mustache rendering services.
*/
public class Template : MustacheBoxable {
    
    /**
    Parses a template string, and returns a template.
    
    Since templates usually compile fine, you don't have to explicitly perform
    any error handling:
    
    ::
    
      let template = Template(string: ...)!
      let rendering = template.render(...)!
    
    Eventual partial tags refer to resources with extension ``.mustache`` stored
    in the main bundle:
    
    ::
    
      // Uses `partial.mustache` resource from the main bundle
      let template = Template(string: "...{{>partial}}...")!
    
    :param: string The template string
    :param: error  If there is an error loading or parsing template and
                   partials, upon return contains an NSError object that
                   describes the problem.
    
    :returns: The created template
    */
    public convenience init?(string: String, error: NSErrorPointer = nil) {
        let repository = RenderingEngine.currentTemplateRepository() ?? TemplateRepository(bundle: nil)
        let contentType = RenderingEngine.currentContentType()
        if let templateAST = repository.templateAST(string: string, contentType: contentType, templateID: nil, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template file, and returns a template.
    
    Since templates usually compile fine, you don't have to explicitly perform
    any error handling:
    
    ::
    
      let template = Template(path: ...)!
      let rendering = template.render(...)!
    
    Eventual partial tags in the template refer to sibling template files using
    the same extension.
    
    ::
    
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
        let repository = TemplateRepository(directoryPath: path.stringByDeletingLastPathComponent, templateExtension: path.pathExtension, encoding: encoding)
        let templateName = path.stringByDeletingPathExtension.lastPathComponent
        if let templateAST = repository.templateAST(named: templateName, relativeToTemplateID: nil, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template file, and returns a template.
    
    Since templates usually compile fine, you don't have to explicitly perform
    any error handling:
    
    ::
    
      let template = Template(URL: ...)!
      let rendering = template.render(...)!
    
    Eventual partial tags in the template refer to sibling templates using
    the same extension.
    
    ::
    
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
        let repository = TemplateRepository(baseURL: URL.URLByDeletingLastPathComponent!, templateExtension: URL.pathExtension, encoding: encoding)
        let templateName = URL.URLByDeletingPathExtension?.lastPathComponent
        if let templateAST = repository.templateAST(named: templateName!, relativeToTemplateID: nil, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    /**
    Parses a template resource identified by the specified name and file
    extension, and returns a template.
    
    Since templates usually compile fine, you don't have to explicitly perform
    any error handling:
    
    ::
    
      let template = Template(named: ...)!
      let rendering = template.render(...)!
    
    Eventual partial tags in the template refer to template resources using
    the same extension.
    
    ::
    
      // `{{>partial}}` in `template.mustache` resouce loads `partial.mustache`:
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
        if let templateAST = repository.templateAST(named: name, relativeToTemplateID: nil, error: error) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    
    // MARK: - Rendering Templates
    
    /**
    Renders a template with a context stack initialized with the provided value
    on top of the base context.
    
    :param: value A value used for evaluating Mustache tags
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
    Returns the rendering of the receiver, given a rendering context.
    
    This method does not return a String, but a Rendering value that wraps both
    the rendered string and its content type (HTML or Text). It is intended to
    be used when you want to perform custom rendering in a RenderFunction.
    
    :param: context A rendering context
    :param: error   If there is an error rendering the tag, upon return contains
                    an NSError object that describes the problem.
    
    :returns: The template rendering
    
    :see: RenderFunction
    */
    public func render(context: Context, error: NSErrorPointer) -> Rendering? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        RenderingEngine.pushCurrentTemplateRepository(repository)
        let rendering = renderingEngine.render(templateAST, error: error)
        RenderingEngine.popCurrentTemplateRepository()
        return rendering
    }
    
    
    // MARK: - Configuring Templates
    
    /**
    The template's base context: all rendering start from this context.
    
    Its default value comes from the configuration of the template
    repository this template comes from.
    
    :see: repository
    */
    public var baseContext: Context
    
    public func extendBaseContext(box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
    
    public func registerInBaseContext(key: String, _ box: MustacheBox) {
        baseContext = baseContext.contextWithRegisteredKey(key, box: box)
    }
    
    
    // MARK: - Accessing Sibling Templates
    
    /**
    The template repository that issued the receiver.
    
    All templates belong a template repository:
    
    - Templates returned by ``init(string:, error:)`` have a template repository
      that loads templates and partials stored as resources in the main bundle,
      with extension ".mustache", encoded in UTF8.
    
    - Templates returned by ``init(path:, error:)`` have a template repository
      that loads templates and partials stored in the directory of the receiver,
      with the same file extension ".mustache", encoded in UTF8.
    
    - Templates returned by ``init(URL:, error:)`` have a template repository
      that loads templates and partials stored in the directory of the receiver,
      with the same file extension ".mustache", encoded in UTF8.
    
    - Templates returned by ``init(named:, bundle:, templateExtension:, encoding:, error:)``
      have a template repository that loads templates and partials stored as
      resources in the specified bundle, with extension ".mustache", encoded in
      UTF8.
    
    - Templates returned by ``TemplateRepository.template(named:, error:)`` and
      `TemplateRepository.template(string:, :error:)` belong to the invoked
      repository.
    
    :see: TemplateRepository
    :see: init(string:, error:)
    :see: init(path:, error:)
    :see: init(URL:, error:)
    :see: init(named:, bundle:, templateExtension:, encoding:, error:)
    */
    public let repository: TemplateRepository
    
    
    // MARK: - MustacheBoxable
    
    public var mustacheBox: MustacheBox {
        return Box(
            value: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
              return self.render(info.context, error: error)
            })
    }

    
    // MARK: - Not public
    
    private let templateAST: TemplateAST
    
    init(repository: TemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.repository = repository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
}
