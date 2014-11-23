//
//  Template.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class Template: MustacheRenderable {
    private let repository: TemplateRepository
    private let templateAST: TemplateAST
    public var baseContext: Context
    
    init(repository: TemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.repository = repository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
    public convenience init?(string: String, error outError: NSErrorPointer = nil) {
        let repository = RenderingEngine.currentTemplateRepository() ?? TemplateRepository(bundle: nil)
        let contentType = RenderingEngine.currentContentType()
        if let templateAST = repository.templateAST(string: string, contentType: contentType, templateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    public convenience init?(path: String, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = TemplateRepository(directoryPath: path.stringByDeletingLastPathComponent, templateExtension: path.pathExtension, encoding: encoding)
        let templateName = path.stringByDeletingPathExtension.lastPathComponent
        if let templateAST = repository.templateAST(named: templateName, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    public convenience init?(URL: NSURL, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = TemplateRepository(baseURL: URL.URLByDeletingLastPathComponent!, templateExtension: URL.pathExtension, encoding: encoding)
        let templateName = URL.URLByDeletingPathExtension?.lastPathComponent
        if let templateAST = repository.templateAST(named: templateName!, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    public convenience init?(named name: String, bundle: NSBundle? = nil, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = TemplateRepository(bundle: bundle, templateExtension: templateExtension, encoding: encoding)
        if let templateAST = repository.templateAST(named: name, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: TemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    public func render(_ value: Value = Value(), error outError: NSErrorPointer = nil) -> String? {
        let rendering = render(baseContext.contextByAddingValue(value))
        switch rendering {
        case .Error(let error):
            if outError != nil {
                outError.memory = error
            }
            return nil
        case .Success(let string, let _):
            return string
        }
    }
    
    
    // MARK: - MustacheRenderable
    
    public func mustacheRender(renderingInfo: RenderingInfo) -> Rendering {
        return render(renderingInfo.context)
    }
    
    
    // MARK: - Private
    
    private func render(context: Context) -> Rendering {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        RenderingEngine.pushCurrentTemplateRepository(repository)
        let rendering = renderingEngine.render(templateAST)
        RenderingEngine.popCurrentTemplateRepository()
        return rendering
    }
}
