import Mustache

let strong = Filter(.HTML) { (string: String, error: NSErrorPointer) in
    return "<strong>\(string)</strong>"
}

let template = Template(string: "{{ strong(x) }}")!
template.registerInBaseContext("strong", Box(strong))

// Renders "<strong>Arthur &amp; Barbara</strong>", "<strong>123</strong>"
var rendering: String
rendering = template.render(Box(["x": "Arthur & Barbara"]))!
rendering = template.render(Box(["x": 123]))!
