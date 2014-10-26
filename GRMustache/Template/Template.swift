//
//  Template.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

public class Template {
    let templateRepository: TemplateRepository
    let templateAST: TemplateAST
    let baseContext: Context
    
    init(templateRepository: TemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.templateRepository = templateRepository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
    func render(object: MustacheValue, error outError: NSErrorPointer) -> String? {
        let context = baseContext.contextByAddingValue(object)
        if let (rendering, _) = renderContentWithContext(context, error: outError) {
            return rendering
        } else {
            return nil
        }
    }
    
    
    // MARK: - Private
    
    private func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> (String, ContentType)? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        return renderingEngine.renderTemplateAST(templateAST, error: outError)
    }
}
