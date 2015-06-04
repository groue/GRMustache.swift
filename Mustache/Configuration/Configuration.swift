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


/**
Configuration of GRMustache

You have three levels of configuration:

- global, through Mustache.DefaultConfiguration
- per template repository, through TemplateRepository.configuration
- per template, through Template properties
*/
public struct Configuration {
    
    // =========================================================================
    // MARK: - Creating Factory Configuration
    
    /**
    Returns a factory configuration.
    
    Its contentType is HTML, baseContext empty, tag delimiters "{{" and "}}".
    */
    public init() {
        contentType = .HTML
        baseContext = Context()
        tagDelimiterPair = TagDelimiterPair(start: "{{", end: "}}")
    }
    
    
    // =========================================================================
    // MARK: - Set Up Configuration
    
    /**
    The content type of strings rendered by templates built with this
    configuration.
    
    It affects the HTML-escaping of your data:
    
    - The `.HTML` content type has templates render HTML. This is the default
      behavior. HTML template escape the input of variable tags such as
      `{{name}}`. Use triple mustache tags `{{{content}}}` in order to avoid the
      HTML-escaping.
    
    - The `.Text` content type has templates render text. They do not
      HTML-escape their input: `{{name}}` and `{{{name}}}` have identical,
      non-escaped, renderings.
    
    GRMustache safely keeps track of the content type of templates: should a
    HTML template embed a text template, the content of the text template would
    be HTML-escaped.
    
    Setting the contentType of a configuration affects the contentType of all
    templates loaded afterwards:
    
        // Globally, with Mustache.DefaultConfiguration:
    
        Mustache.DefaultConfiguration.contentType = .Text
        let textTemplate = Template(named: "Script")!
    
        // Locally, using a TemplateRepository:
    
        let repository = TemplateRepository(bundle: NSBundle.mainBundle())
        repository.configuration.contentType = .HTML
        let HTMLTemplate = repository.template(named: "HTMLDocument")!
    
    In order to set the content type of an individual templates, use pragma tags
    right in the content of your templates:
    
    - `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
    - `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.
    
    For example:
    
        {{! This template renders a bash script. }}
        {{% CONTENT_TYPE:TEXT }}
        export LANG={{ENV.LANG}}
        ...
    
    These pragmas must be found early in the template (before any value tag).
    Should several pragmas be found in a template content, the last one wins.
    */
    public var contentType: ContentType
    
    /**
    The base context for templates rendering. All templates built with this
    configuration can access values stored in the base context.
    
    The default base context is empty.
    
    You can set it to some custom context, or extend it with the
    `extendBaseContext` and `registerInBaseContext` methods.
    
        // Globally, with Mustache.DefaultConfiguration:
    
        Mustache.DefaultConfiguration.baseContext = Context(Box(["foo": "bar"]))

        // Renders "bar"
        let template1 = Template(string: "{{foo}}")!
        template1.render()!
    
        // Locally, using a TemplateRepository:
        
        let repository = TemplateRepository(bundle: NSBundle.mainBundle())
        repository.configuration.extendBaseContext(Box(["baz": "qux"]))
        
        // Renders "bar, qux"
        let template2 = repository.template(string: "{{foo}}, {{baz}}")!
        template2.render()!
    
    :see: extendBaseContext
    :see: registerInBaseContext
    */
    public var baseContext: Context
    
    /**
    Extends the base context with the provided boxed value. All templates built
    with this configuration can access its keys.
    
        Mustache.DefaultConfiguration.extendBaseContext(Box(["foo": "bar"]))

        // Renders "bar"
        let template = Template(string: "{{foo}}")!
        template.render()!
    
    :param: box The box pushed on the top of the context stack
    
    :see: baseContext
    :see: registerInBaseContext
    :see: Context.extendedContext
    */
    public mutating func extendBaseContext(box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
    
    /**
    Registers a key in the base context. All renderings will be able to access
    the provided box through this key.
    
    Registered keys are looked up first when evaluating Mustache tags.
    
        Mustache.DefaultConfiguration.registerInBaseContext("foo", Box("bar"))

        // Renders "bar"
        let template = Template(string: "{{foo}}")!
        template.render()!

        // Renders "bar" again, because the registered key "foo" has priority.
        template.render(Box(["foo": "qux"]))!
    
    :param: key An identifier
    :param: box The box registered for `key`
    
    :see: baseContext
    :see: extendBaseContext
    :see: Context.contextWithRegisteredKey
    */
    public mutating func registerInBaseContext(key: String, _ box: MustacheBox) {
        baseContext = baseContext.contextWithRegisteredKey(key, box: box)
    }
    
    /**
    The delimiters for Mustache tags. All templates built with this
    configuration are parsed using those delimiters.
    
    The default value is `{{`, `}}`.
    
    Setting the tagDelimiterPair of a configuration affects all templates loaded
    afterwards:
    
        // Globally, with Mustache.DefaultConfiguration:
    
        Mustache.DefaultConfiguration.tagDelimiterPair = TagDelimiterPair(start: "<%", end: "%>")
        let template1 = Template(string: "<% name %>)!
    
        // Locally, using a TemplateRepository:
    
        let repository = TemplateRepository(bundle: NSBundle.mainBundle())
        repository.configuration.tagDelimiterPair = TagDelimiterPair(start: "[[", end: "]]")
        let HTMLTemplate = repository.template(string: "[[ name ]]")!
    
    You can also change the delimiters right in your templates using a "Set
    Delimiter tag": `{{=[[ ]]=}}` changes delimiters to `[[` and `]]`.
    */
    public var tagDelimiterPair: TagDelimiterPair
    
}

/**
The default configuration that is used unless specified otherwise by a
TemplateRepository.

:see: Configuration
:see: TemplateRepository
*/
public var DefaultConfiguration = Configuration()
