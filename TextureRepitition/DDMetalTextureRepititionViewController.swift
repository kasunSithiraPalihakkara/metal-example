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
    var objectToDrawOnRequest: Square!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    var textureLoader: MTKTextureLoader! = nil
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    let tapSensivity:Float = 1.5
    var lastTapLocation: CGPoint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        device = MTLCreateSystemDefaultDevice()
        textureLoader = MTKTextureLoader(device: device)
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        

        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
       
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        objectToDraw = Square(device: device,textureLoader: textureLoader)
        objectToDraw.positionX = 0
        objectToDraw.positionY =  0
        objectToDraw.rotationZ = float4x4.degrees(toRad: 45)
        objectToDraw.scale = 0.4
        
       
//        objectToDrawOnRequest = Square(device: device, textureLoader: textureLoader)
//        objectToDrawOnRequest.positionX = 0.8
//        objectToDrawOnRequest.positionY =  0.8
//        objectToDrawOnRequest.rotationZ = float4x4.degrees(toRad: 45)
//        objectToDrawOnRequest.scale = 0.4
        
        timer = CADisplayLink(target: self, selector: #selector(DDMetalTextureRepititionViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        setupGestures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func render() {
       
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
        
//      guard let drawableOnRequest = metalLayer?.nextDrawable() else { return }
//      objectToDrawOnRequest.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawableOnRequest, clearColor: nil)

    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
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
           
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            
            objectToDraw.positionX -= xDelta
            objectToDraw.positionY += yDelta
            
            print("objectToDraw.positionX: \(objectToDraw.positionX) objectToDraw.positionY:\(objectToDraw.positionY)")
            
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began {
            lastPanLocation = panGesture.location(in: self.view)
        }
    }
    
    func tapBlurButton(tapGesture: UITapGestureRecognizer) {
        
         let pointInView = tapGesture.location(in: self.view)
        
         print("PointInView: \(pointInView)")
        
          let xDelta = Float((lastTapLocation.x - pointInView.x)/self.view.bounds.width)*tapSensivity
          let yDelta = Float((lastTapLocation.y - pointInView.y)/self.view.bounds.height)*tapSensivity
        
         objectToDraw.positionX = -xDelta
         objectToDraw.positionY =  yDelta
        
         print("objectToDraw.positionX: \(objectToDraw.positionX) objectToDraw.positionY:\(objectToDraw.positionY)")
        
         lastTapLocation = pointInView;
    }
}

