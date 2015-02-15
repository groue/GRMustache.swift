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

public typealias TemplateID = String

public protocol TemplateRepositoryDataSource {
    func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID?
    func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String?
}

public class TemplateRepository {
    
    // =========================================================================
    // MARK: - Creating Template Repositories
    
    /**
    Returns a TemplateRepository which loads template through the provided
    dataSource.
    
    The dataSource is optional: repositories without dataSource can not load
    templates by name, and can only parse template strings:
    
    ::
    
      let repository = TemplateRepository()
      let template = repository.template(string: "Hello {{name}}")!
    
    */
    public init(dataSource: TemplateRepositoryDataSource? = nil) {
        configuration = DefaultConfiguration
        templateASTForTemplateID = [:]
        self.dataSource = dataSource
    }
    
    /**
    Returns a TemplateRepository that loads templates from a dictionary.
    
    ::
    
      let templates = ["template": "Hulk Hogan has a Mustache."]
      let repository = TemplateRepository(templates: templates)
    
      // Renders "Hulk Hogan has a Mustache." twice
      repository.template(named: "template")!.render()!
      repository.template(string: "{{>template}}")!.render()!
    
    :param: templates A dictionary whose keys are template names and values
                      template strings.
    */
    convenience public init(templates: [String: String]) {
        self.init(dataSource: DictionaryDataSource(templates: templates))
    }
    
    /**
    Returns a TemplateRepository that loads templates from a directory.
    
    ::
    
      let repository = TemplateRepository(directoryPath: "/path/to/templates")
    
      // Loads /path/to/templates/template.mustache
      let template = repository.template(named: "template")!
    
    :param: directoryPath     The path to the directory containing template
                              files.
    :param: templateExtension The extension of template files. Default extension
                              is "mustache".
    :param: encoding          The encoding of template files. Default encoding
                              is NSUTF8StringEncoding.
    */
    convenience public init(directoryPath: String, templateExtension: String? = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: DirectoryDataSource(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding))
    }
    
    /**
    Returns a TemplateRepository that loads templates from a URL.
    
    ::
    
      let templatesURL = NSURL.fileURLWithPath("/path/to/templates")!
      let repository = TemplateRepository(baseURL: templatesURL)
    
      // Loads /path/to/templates/template.mustache
      let template = repository.template(named: "template")!
    
    :param: baseURL           The base URL where to look for templates.
    :param: templateExtension The extension of template files. Default extension
                              is "mustache".
    :param: encoding          The encoding of template files. Default encoding
                              is NSUTF8StringEncoding.
    */
    convenience public init(baseURL: NSURL, templateExtension: String? = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: URLDataSource(baseURL: baseURL, templateExtension: templateExtension, encoding: encoding))
    }
    
    /**
    Returns a TemplateRepository that loads templates stored as resources in a
    bundle.
    
    ::
    
      let repository = TemplateRepository(bundle: nil)
    
      // Loads the template.mustache resource of the main bundle:
      let template = repository.template(named: "template")!
    
    :param: bundle            The bundle that stores templates as resources.
                              Nil stands for the main bundle.
    :param: templateExtension The extension of template files. Default extension
                              is "mustache".
    :param: encoding          The encoding of template files. Default encoding
                              is NSUTF8StringEncoding.
    */
    convenience public init(bundle: NSBundle?, templateExtension: String? = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: BundleDataSource(bundle: bundle ?? NSBundle.mainBundle(), templateExtension: templateExtension, encoding: encoding))
    }
    
    
    // =========================================================================
    // MARK: - Configuring Template Repositories
    
    /**
    The configuration for all templates and partials built by the repository.
    
    It is initialized with the value of Mustache.DefaultConfiguration.
    
    You can alter the repository's configuration, or set it to another value:
    
    ::
    
      // Reset the configuration to the factory configuration and change tag
      // delimiters:
      let repository = TemplateRepository()
      repository.configuration = Configuration()
      repository.configuration.tagStartDelimiter = "<%"
      repository.configuration.tagEndDelimiter = "%>"
    
      // Renders "Hello Luigi"
      let template = repository.template(string: "Hello <%name%>")!
      template.render(Box(["name": "Luigi"]))!
    
    Important: changing the configuration has no effect after the repository has
    loaded one template.
    */
    public var configuration: Configuration
    
    
    // =========================================================================
    // MARK: - Loading Templates from a Repository
    
    public let dataSource: TemplateRepositoryDataSource?
    
    public func template(#string: String, error: NSErrorPointer = nil) -> Template? {
        return self.template(string: string, contentType: lockedConfiguration.contentType, error: error)
    }
    
    public func template(named name: String, error: NSErrorPointer = nil) -> Template? {
        if let templateAST = templateAST(named: name, relativeToTemplateID: nil, error: error) {
            return Template(repository: self, templateAST: templateAST, baseContext: lockedConfiguration.baseContext)
        } else {
            return nil
        }
    }
    
    public func reloadTemplates() {
        templateASTForTemplateID.removeAll()
    }
    
    
    // =========================================================================
    // MARK: - Internal
    
    func template(#string: String, contentType: ContentType, error: NSErrorPointer) -> Template? {
        if let templateAST = self.templateAST(string: string, contentType: contentType, templateID: nil, error: error) {
            return Template(repository: self, templateAST: templateAST, baseContext: lockedConfiguration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateAST(named name: String, relativeToTemplateID templateID: TemplateID?, error: NSErrorPointer) -> TemplateAST? {
        if let templateID = dataSource?.templateIDForName(name, relativeToTemplateID: templateID, inRepository: self) {
            if let templateAST = templateASTForTemplateID[templateID] {
                return templateAST
            } else {
                var dataSourceError: NSError?
                if let templateString = dataSource?.templateStringForTemplateID(templateID, error: &dataSourceError) {
                    let templateAST = TemplateAST()
                    templateASTForTemplateID[templateID] = templateAST
                    if let compiledAST = self.templateAST(string: templateString, contentType: lockedConfiguration.contentType, templateID: templateID, error: error) {
                        templateAST.updateFromTemplateAST(compiledAST)
                        return templateAST
                    } else {
                        templateASTForTemplateID.removeValueForKey(templateID)
                        return nil
                    }
                } else {
                    if dataSourceError == nil {
                        dataSourceError = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
                    }
                    if error != nil {
                        error.memory = dataSourceError
                    }
                    return nil
                }
            }
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
            }
            return nil
        }
    }
    
    func templateAST(#string: String, contentType: ContentType, templateID: TemplateID?, error: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType, repository: self, templateID: templateID)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: lockedConfiguration)
        parser.parse(string, templateID: templateID)
        return compiler.templateAST(error: error)
    }
    
    
    // =========================================================================
    // MARK: - Private
    
    private var _lockedConfiguration: Configuration?
    private var lockedConfiguration: Configuration {
        // Changing mutable values within the repository's configuration no
        // longer has any effect.
        if _lockedConfiguration == nil {
            _lockedConfiguration = configuration
        }
        return _lockedConfiguration!
    }
    private var templateASTForTemplateID: [TemplateID: TemplateAST]
    
    private class DictionaryDataSource: TemplateRepositoryDataSource {
        let templates: [String: String]
        
        init(templates: [String: String]) {
            self.templates = templates
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            return name
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return templates[templateID]
        }
    }
    
    private class DirectoryDataSource: TemplateRepositoryDataSource {
        let directoryPath: String
        let templateExtension: String?
        let encoding: NSStringEncoding
        
        init(directoryPath: String, templateExtension: String?, encoding: NSStringEncoding) {
            self.directoryPath = directoryPath
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if let templateExtension = self.templateExtension {
                    if !templateExtension.isEmpty {
                        return normalizedName.stringByAppendingPathExtension(templateExtension)!
                    }
                }
                return normalizedName
            }()
            
            let templateDirectoryPath: String = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return normalizedBaseTemplateID.stringByDeletingLastPathComponent
                } else {
                    return self.directoryPath
                }
            }()
            
            return templateDirectoryPath.stringByAppendingPathComponent(templateFilename).stringByStandardizingPath
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: error)
        }
    }
    
    private class URLDataSource: TemplateRepositoryDataSource {
        let baseURL: NSURL
        let templateExtension: String?
        let encoding: NSStringEncoding
        
        init(baseURL: NSURL, templateExtension: String?, encoding: NSStringEncoding) {
            self.baseURL = baseURL
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if let templateExtension = self.templateExtension {
                    if !templateExtension.isEmpty {
                        return normalizedName.stringByAppendingPathExtension(templateExtension)!
                    }
                }
                return normalizedName
                }()
            
            let templateBaseURL: NSURL = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return NSURL(string: normalizedBaseTemplateID)!
                } else {
                    return self.baseURL
                }
            }()
            
            return NSURL(string: templateFilename, relativeToURL: templateBaseURL)!.URLByStandardizingPath!.absoluteString
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfURL: NSURL(string: templateID)!, encoding: encoding, error: error)
        }
    }
    
    private class BundleDataSource: TemplateRepositoryDataSource {
        let bundle: NSBundle
        let templateExtension: String?
        let encoding: NSStringEncoding
        
        init(bundle: NSBundle, templateExtension: String?, encoding: NSStringEncoding) {
            self.bundle = bundle
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository: TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                var relativePath = normalizedBaseTemplateID.stringByDeletingLastPathComponent
                relativePath = relativePath.stringByReplacingOccurrencesOfString(bundle.resourcePath!, withString:"")
                return bundle.pathForResource(normalizedName, ofType: templateExtension, inDirectory: relativePath)
            } else {
                return bundle.pathForResource(normalizedName, ofType: templateExtension)
            }
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: error)
        }
    }
}
