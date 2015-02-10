import Mustache

let template = Template(string: "Hello {{name}}")!
let data = ["name": "Arthur"]
let rendering = template.render(Box(data))!
