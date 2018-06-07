
import Foundation
import MetalKit

class Square: Node {
    var verticesArray:Array<Vertex>
  
    init(device: MTLDevice,textureLoader :MTKTextureLoader){
        
        let textureWidth:float_t = 200.0
        let textureHeight:float_t = 200.0
        let textureCenterX:float_t = 0.0
        let textureCenterY:float_t = 0.0
        
        let A = Vertex(x: textureCenterX-textureWidth/2, y:textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b: 1.0, a:  1.0 , s: 0.0, t: 0.0)
        let B = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 0.0, t: 800.0)
        let C = Vertex(x: textureCenterX+textureWidth/2, y:  textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 800.0, t: 800.0)

        let D = Vertex(x: textureCenterX-textureWidth/2, y:   textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0)
        let E = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 800.0, t: 800.0)
        let F = Vertex(x: textureCenterX+textureWidth/2, y:  textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.0, t: 800.0)
        
        verticesArray = [
            
            A,B,C ,D,E,F
        ]
      
        let path = Bundle.main.path(forResource: "chalk-1", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
       super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture)
        
    }
    
   
    
}
