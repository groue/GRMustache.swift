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
    
    func render(value: MustacheValue, error outError: NSErrorPointer) -> MustacheRendering? {
        let context = baseContext.contextByAddingValue(value)
        return renderContentWithContext(context, error: outError)
    }
    
    
    // MARK: - Private
    
    private func renderContentWithContext(context: Context, error outError: NSErrorPointer) -> MustacheRendering? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        return renderingEngine.renderTemplateAST(templateAST, error: outError)
    }
}
