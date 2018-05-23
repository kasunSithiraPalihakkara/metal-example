//
//  ViewController.swift
//  TextureRepitition
//
//  Created by 4Axis on 5/22/18.
//  Copyright © 2018 4Axis. All rights reserved.
//

import UIKit
import Metal
import simd

class DDMetalTextureRepititionViewController: UIViewController {
    
    var objectToDraw: Square!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
//        objectToDraw = Square(device: device)
//        objectToDraw.positionX = 0
//        objectToDraw.positionY =  0
//       // objectToDraw.rotationZ = float4x4.degrees(toRad: 45)
//        objectToDraw.scale = 0.1
       
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        objectToDraw = Square(device: device, commandQ: commandQueue)
        objectToDraw.positionX = 0
        objectToDraw.positionY =  0
        objectToDraw.rotationZ = float4x4.degrees(toRad: 45)
        objectToDraw.scale = 0.4
        
        timer = CADisplayLink(target: self, selector: #selector(DDMetalTextureRepititionViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }


}

