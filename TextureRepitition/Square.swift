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
    var verticesArray:Array<Vertex>
    let textureWidth:float_t = 200.0
    let textureHeight:float_t = 200.0
    var textureCenterX:float_t = 0.0
    var textureCenterY:float_t = 0.0
    
    init(device: MTLDevice,textureLoader :MTKTextureLoader){
        
      
//        let A = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
//        let B = Vertex(x: -1.0, y:  -1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 1.0)
//        let C = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 1.0, t: 1.0)
//
//        let D = Vertex(x: -1.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
//        let E = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 1.0, t: 1.0)
//        let F = Vertex(x:  1.0, y:   1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 1.0)
        
        let A = Vertex(x: textureCenterX-textureWidth/2, y:textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
        let B = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 800.0)
        let C = Vertex(x: textureCenterX+textureWidth/2, y:  textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 800.0, t: 800.0)

        let D = Vertex(x: textureCenterX-textureWidth/2, y:   textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
        let E = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 800.0, t: 800.0)
        let F = Vertex(x: textureCenterX+textureWidth/2, y:  textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 800.0)
        
//        textureCenterX = 250
//        textureCenterY = 250
        
//        let G = Vertex(x:  500.0, y:   1000.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
//        let H = Vertex(x:  500.0, y:   500.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 800.0)
//        let I = Vertex(x:  1000.0, y:  500.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 800.0, t: 800.0)
//
//        let J = Vertex(x:  500.0, y:   1000.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
//        let K = Vertex(x:  1000.0, y:  500.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 800.0, t: 800.0)
//        let L = Vertex(x:  1000.0, y:   1000.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 800.0)
        
        
       
        verticesArray = [
            
           // G,H,I,J,K,L,
            A,B,C ,D,E,F
        ]
       // verticesArray.append(contentsOf: [A,B,C,D,E,F])
        
        let path = Bundle.main.path(forResource: "texture", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
       super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture)
        
    }
    
   
    
}
