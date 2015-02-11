import Mustache

let twice = Filter { (rendering: Rendering, error: NSErrorPointer) in
    let twice = rendering.string + rendering.string
    return Rendering(twice, rendering.contentType)
}

let template = Template(string: "{{ twice(x) }}")!
template.registerInBaseContext("twice", Box(twice))

// Renders "foofoo", "123123"
var rendering: String
rendering = template.render(Box(["x": "foo"]))!
rendering = template.render(Box(["x": 123]))!
