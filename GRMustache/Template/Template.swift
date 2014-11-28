//
//  Template.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

/**
    The Template class provides Mustache rendering services.
*/
public class Template: MustacheRenderable {
    
    /**
        Parses a template string, and returns a template.
        
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
    
        :param: name               The name of a bundle resource.
        :param: bundle             The bundle where to look for the template
                                   resource. If nil, the main bundle is used.
        :param: templateExtension  If extension is an empty string or nil, the
                                   extension is assumed not to exist and the
                                   template file should exactly matches name.
        :param: encoding           The encoding of template resource.
        :param: error              If there is an error loading or parsing
                                   template and partials, upon return contains
                                   an NSError object that describes the problem.
    
        :returns: The created template
    */
    public convenience init?(named name: String, bundle: NSBundle? = nil, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding, error: NSErrorPointer = nil) {
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
    
    public func render(_ value: Value = Value(), error: NSErrorPointer = nil) -> String? {
        if let rendering = render(baseContext.extendedContext(value: value), error: error) {
            return rendering.string
        } else {
            return nil
        }
    }
    
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
        repository this template comes from. Unless specified otherwize, this
        base context contains the standard library.
        
        :see: repository
    */
    public var baseContext: Context
    
    public func extendBaseContext(# value: Value) {
        baseContext = baseContext.extendedContext(value: value)
    }
    
    public func extendBaseContext(# tagObserver: MustacheTagObserver) {
        baseContext = baseContext.extendedContext(tagObserver: tagObserver)
    }
    
    
    // MARK: - Accessing Sibling Templates
    
    /**
        The template repository that issued the receiver.
    
        All templates belong a template repository:
    
        - Templates returned by ``init(string:, error:)`` have a template
        repository that loads templates and partials stored as resources in
        the main bundle, with extension ".mustache", encoded in UTF8.
    
        - Templates returned by ``init(path:, error:)`` have a template
        repository that loads templates and partials stored in the directory
        of the receiver, with the same file extension ".mustache", encoded in
        UTF8.
    
        - Templates returned by ``init(URL:, error:)`` have a template
        repository that loads templates and partials stored in the directory
        of the receiver, with the same file extension ".mustache", encoded in
        UTF8.
    
        - Templates returned by ``init(named:, bundle:, templateExtension:, encoding:, error:)``
        have a template repository that loads templates and partials stored as
        resources in the specified bundle, with extension ".mustache", encoded
        in UTF8.
    
        - Templates returned by ``TemplateRepository.template(named:, error:)``
        and `TemplateRepository.template(string:, :error:)` belong to
        the invoked repository.
    
        :see: TemplateRepository
        :see: init(string:, error:)
        :see: init(path:, error:)
        :see: init(URL:, error:)
        :see: init(named:, bundle:, templateExtension:, encoding:, error:)
    */
    public let repository: TemplateRepository
    
    
    // MARK: - MustacheRenderable
    
    // TODO: make this method internal
    public func render(info: RenderingInfo, error: NSErrorPointer = nil) -> Rendering? {
        return render(info.context, error: error)
    }
    
    
    // MARK: - Not public
    
    private let templateAST: TemplateAST
    
    init(repository: TemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.repository = repository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
}
