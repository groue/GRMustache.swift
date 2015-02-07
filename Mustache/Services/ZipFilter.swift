//
//  ZipFilter.swift
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//


let ZipFilter = VariadicFilter { (boxes, error) -> MustacheBox? in
    
    // Turn collection arguments into generators. Generators can be iterated
    // all together, and this is what we need.
    //
    // Other kinds of arguments generate an error.
    
    var generators: [GeneratorOf<MustacheBox>] = []
    
    for box in boxes {
        if box.isEmpty {
            // Missing collection is empty collection
            generators.append(GeneratorOf((EmptyCollection() as EmptyCollection<MustacheBox>).generate()))
        } else if let array = box.value as? [MustacheBox] {
            // Array
            generators.append(GeneratorOf(array.generate()))
        } else if let set = box.value as? NSSet {
            // Set
            // TODO: test
            var setGenerator = NSFastGenerator(set)
            generators.append(GeneratorOf { setGenerator.next().map { BoxAnyObject($0) } })
        } else {
            // Error
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Non-enumerable argument in zip filter: `\(box.value)`"])
            }
            return nil
        }
    }
    
    
    // Build an array of custom render functions
    
    var renderFunctions: [RenderFunction] = []
    
    while true {
        
        // Extract from all generators the boxes that should enter the
        // rendering context at each iteration.
        //
        // Given the [1,2,3], [a,b,c] input collections, those objects
        // would be [1,a] then [2,b] and finally [3,c].
        
        var boxes: [MustacheBox] = []
        for generator in generators {
            var generator = generator
            if let box = generator.next() {
                boxes.append(box)
            }
        }
        
        
        // All iterators have been enumerated: stop
        
        if boxes.isEmpty {
            break;
        }
        
        
        // Build a render function which extends the rendering context
        
        let renderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            var context = info.context
            for box in boxes {
                context = context.extendedContext(box)
            }
            return info.tag.render(context)
        }
        
        renderFunctions.append(renderFunction)
    }
    
    
    // Return a box of those boxed render functions
    
    return Box(map(renderFunctions) { Box($0) })
}