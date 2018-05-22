//
//  Square.swift
//  TextureRepitition
//
//  Created by 4Axis on 5/22/18.
//  Copyright © 2018 4Axis. All rights reserved.
//

import Foundation
import Metal

class Square: Node {
    
    init(device: MTLDevice){
        
      
        let A = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let B = Vertex(x: -1.0, y:  -1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        let C = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        
        let D = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let E = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        let F = Vertex(x:  1.0, y:   1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        
        
        let verticesArray:Array<Vertex> = [
            A,B,C ,D,E,F
        ]
        super.init(name: "Triangle", vertices: verticesArray, device: device)
    }
    
}
