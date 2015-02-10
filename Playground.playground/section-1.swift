import Mustache

let succ = Filter { (i: Int, error: NSErrorPointer) in
    return Box(i + 1)
}

let template = Template(string: "{{ succ(x) }}")!
template.registerInBaseContext("succ", Box(succ))

// Renders "2", "3", "4"
var rendering = template.render(Box(["x": 1]))!
rendering = template.render(Box(["x": 2.0]))!
rendering = template.render(Box(["x": NSNumber(float: 3.1415)]))!

// Error evaluating {{ succ(x) }} at line 1: Unexpected argument type
var error: NSError?
template.render(Box(), error: &error)
error?.localizedDescription
