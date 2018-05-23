//
//  Square.swift
//  TextureRepitition
//
//  Created by 4Axis on 5/22/18.
//  Copyright © 2018 4Axis. All rights reserved.
//

import Foundation
import MetalKit

class Square: Node {
    
    init(device: MTLDevice, commandQ: MTLCommandQueue,textureLoader :MTKTextureLoader){
        
      
        let A = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
        let B = Vertex(x: -1.0, y:  -1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 1.0)
        let C = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 1.0, t: 1.0)
        
        let D = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
        let E = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 1.0, t: 1.0)
        let F = Vertex(x:  1.0, y:   1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 1.0)
        
        
        let verticesArray:Array<Vertex> = [
            A,B,C ,D,E,F
        ]
        
        let path = Bundle.main.path(forResource: "texture", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture)
    }
    
}
