import Mustache

let square = Filter { (x: Int, error: NSErrorPointer) in
    return Box(x * x)
}

// Renders "100"
let template = Template(string: "{{square(x)}}")!
let rendering = template.render(Box(["x": 10]))!