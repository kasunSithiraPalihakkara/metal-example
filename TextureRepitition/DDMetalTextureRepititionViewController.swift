//
//  ViewController.swift
//  TextureRepitition
//
//  Created by 4Axis on 5/22/18.
//  Copyright © 2018 4Axis. All rights reserved.
//

import UIKit
import MetalKit
import simd

class DDMetalTextureRepititionViewController: UIViewController {
    
    var objectToDraw: Square!
    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var textureLoader: MTKTextureLoader! = nil
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    let tapSensivity:Float = 3.0
    var lastTapLocation: CGPoint!
    var screenBoundryScaleFactor:Float = 5.0
    
    var viewPortSize:vector_uint2 = vector_uint2([UInt32(0),UInt32(0)])
    
    
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
           
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        device = MTLCreateSystemDefaultDevice()
        textureLoader = MTKTextureLoader(device: device)
        mtkView.device = device
        

        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
       
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        //-blending
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add;
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add;
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one;
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one;
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha;
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha;
        //-
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        objectToDraw = Square(device: device,textureLoader: textureLoader)
        objectToDraw.positionX = 0
        objectToDraw.positionY =  0
       // objectToDraw.rotationZ = float4x4.degrees(toRad: 90)
        objectToDraw.scale = 0.4
        print("vertex array:\(objectToDraw.verticesArray.count)")
        

        setupGestures()
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if let window = view.window {
//            let scale = window.screen.nativeScale
//            let layerSize = view.bounds.size
//
//            view.contentScaleFactor = scale
//            metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
//            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
//
//        }
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

     func render(_ drawable: CAMetalDrawable?) {
       
        guard let drawable = drawable else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable,viewportSize:viewPortSize, clearColor: nil)
        
    }
    
    //MARK: - Gesture related
    
    func setupGestures(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DDMetalTextureRepititionViewController.pan))
        self.view.addGestureRecognizer(pan)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DDMetalTextureRepititionViewController.tapBlurButton))
        self.view.addGestureRecognizer(tapGesture)
        
        let pointInView = tapGesture.location(in: self.view)
        lastTapLocation = pointInView;
    }
    
    func pan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == UIGestureRecognizerState.changed {
            let pointInView = panGesture.location(in: self.view)
            print("pointInView:\(pointInView)")
            
//            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
//            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            
//            objectToDraw.positionX -= xDelta
//            objectToDraw.positionY += yDelta
            
            print("objectToDraw.positionX: \(objectToDraw.positionX) objectToDraw.positionY:\(objectToDraw.positionY)")
            
            //-constantly draw images
            var touchPoint:CGPoint = convertCoodinates(tapx:pointInView.x , tapy:pointInView.y )
            print("touchPoint:\(touchPoint)")
            
            let textureWidth:Float = 200.0
            let textureHeight:Float = 200.0
            var textureCenterX:Float = Float(touchPoint.x)*screenBoundryScaleFactor //change number if you need to bigger canvas
            var textureCenterY:Float = Float(touchPoint.y)*screenBoundryScaleFactor

            let A = Vertex(x: textureCenterX-textureWidth/2, y:textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
            let B = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 800.0)
            let C = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 800.0, t: 800.0)

            let D = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
            let E = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 800.0, t: 800.0)
            let F = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 800.0)



            objectToDraw.verticesArray.append(contentsOf: [A,B,C,D,E,F])
            print("verticesArray count:\(objectToDraw.verticesArray.count)")

            objectToDraw.allocateMemoryForVetexBuffer(vertices:objectToDraw.verticesArray)
         
            //-works if you need to drag the texture
//            var verticesArray:Array<Vertex>  = [
//                A,B,C ,D,E,F
//            ]
//            objectToDraw.allocateMemoryForVetexBuffer(vertices:verticesArray)
            
            //-
            
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began {
            lastPanLocation = panGesture.location(in: self.view)
        }
    }
    
    func tapBlurButton(tapGesture: UITapGestureRecognizer) {
        
         let pointInView = tapGesture.location(in: self.view)
        
        print("PointInView: \(pointInView)")

        //implementing copy image
        
        var touchPoint:CGPoint = convertCoodinates(tapx:pointInView.x , tapy: pointInView.y)
        
        let textureWidth:Float = 200.0
        let textureHeight:Float = 200.0
        var textureCenterX:Float = Float(touchPoint.x)*screenBoundryScaleFactor //change number if you need to bigger canvas
        var textureCenterY:Float = Float(touchPoint.y)*screenBoundryScaleFactor
        
        let A = Vertex(x: textureCenterX-textureWidth/2, y:textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0 , s: 0.0, t: 0.0)
        let B = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0 , s: 0.0, t: 800.0)
        let C = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0 , s: 800.0, t: 800.0)

        let D = Vertex(x: textureCenterX-textureWidth/2, y: textureCenterY+textureHeight/2, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0)
        let E = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY-textureHeight/2, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 800.0, t: 800.0)
        let F = Vertex(x: textureCenterX+textureWidth/2, y: textureCenterY+textureHeight/2, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.0, t: 800.0)
        
        
        
//        objectToDraw.verticesArray.append(contentsOf: [A,B,C,D,E,F])
//        print("verticesArray count:\(objectToDraw.verticesArray.count)")
//
//        objectToDraw.allocateMemoryForVetexBuffer(vertices:objectToDraw.verticesArray)
        
        //-works if you need to drag the texture
        var verticesArray:Array<Vertex>  = [
            A,B,C ,D,E,F
        ]
        objectToDraw.allocateMemoryForVetexBuffer(vertices:verticesArray)
        
        //-
        
        lastTapLocation = pointInView;
    }
    
    func convertCoodinates(tapx:CGFloat,tapy:CGFloat) -> CGPoint{
        let deviceWidth:CGFloat = CGFloat(viewPortSize.x)
        let deviceHeight:CGFloat = CGFloat(viewPortSize.y)
        var touchPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
        
        if (tapx <= deviceWidth/4) && (tapy <= deviceHeight/4) {
            touchPoint.x = -(deviceWidth/4-tapx)
            touchPoint.y = deviceHeight/4-tapy
        }else if (tapx > deviceWidth/4) && (tapy <= deviceHeight/4) {
            touchPoint.x = tapx-deviceWidth/4
            touchPoint.y = deviceHeight/4-tapy
        }else if (tapx <= deviceWidth/4) && (tapy > deviceHeight/4) {
            touchPoint.x = -(deviceWidth/4-tapx)
            touchPoint.y = -(tapy-deviceHeight/4)
        }else if (tapx > deviceWidth/4) && (tapy > deviceHeight/4) {
            touchPoint.x = tapx-deviceWidth/4
            touchPoint.y = -(tapy-deviceHeight/4)
        }
        
        return touchPoint
        
    }
    
}
// MARK: - MTKViewDelegate

extension DDMetalTextureRepititionViewController: MTKViewDelegate {
    
/// Called whenever view changes orientation or is resized
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
      
        viewPortSize.x = UInt32(size.width);
        viewPortSize.y = UInt32(size.height);
        print("viewPort \( viewPortSize)")
    }
    
/// Called whenever the view needs to render a frame
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
    
}
