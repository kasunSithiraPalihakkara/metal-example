//
//  Node.swift
//  TextureRepitition
//
//  Created by 4Axis on 5/22/18.
//  Copyright © 2018 4Axis. All rights reserved.
//


import Foundation
import Metal
import QuartzCore
import simd
class Node {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
//  var vertexBuffer: MTLBuffer
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    var bufferProvider: BufferProvider
    
    var texture: MTLTexture
    
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(device: self.device)
    
    var count = 0
    var vertexData = Array<Float>()
   
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture) {
       
     //  var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }

        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
     //   vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
        self.texture = texture
        
//        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * float4x4.numberOfElements() * 2)
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * float4x4.numberOfElements() * 2,sizeOfVertexBuffer:dataSize*10000)
    }
    

    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable,viewportSize:vector_uint2, clearColor: MTLClearColor?){
        
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        commandBuffer.addCompletedHandler { (_) in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        // Set the region of the drawable to which we'll draw.
        
        let viewport:MTLViewport = (MTLViewport)(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1.0, zfar: 1.0 )
        renderEncoder.setViewport(viewport)
        
        
        
        renderEncoder.setRenderPipelineState(pipelineState)
 //     renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        let vertexBuffer = bufferProvider.nextVertexBuffer(verticesArray: vertexData)
         renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        
        //-
        let input = viewportSize
        var value = input
        let data = withUnsafePointer(to: &value) {
            Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: input))
        }
        print(data as NSData)
        
      //  let data = <Data from somewhere>
        data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let rawPtr = UnsafeRawPointer(u8Ptr)
            renderEncoder.setVertexBytes(rawPtr, length: MemoryLayout.size(ofValue: viewportSize), at: 2)
        }
        //-
        
   
        renderEncoder.setFragmentTexture(texture, at: 0)
        if let samplerState = samplerState{
            renderEncoder.setFragmentSamplerState(samplerState, at: 0)
        }
        
        let nodeModelMatrix = self.modelMatrix()
        let uniformBuffer = bufferProvider.nextUniformsBuffer(modelViewMatrix: nodeModelMatrix)
         renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
       
        
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable )
        commandBuffer.commit()
    }
    
    func modelMatrix() -> float4x4 {
        var matrix = float4x4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = FLT_MAX
        return device.makeSamplerState(descriptor: sampler)
    }
    
    func allocateMemoryForVetexBuffer(vertices: Array<Vertex>){
       var temVertexData = Array<Float>()
        for vertex in vertices{
            temVertexData += vertex.floatBuffer()
        }
        
       vertexData = temVertexData;
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
       
        count += 1
        print("buffer Count:\(count)")
        
   //   vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
   
   // vertexBuffer.contents().copyBytes(from: vertexData, count: dataSize)
       
       
       
        vertexCount = vertices.count
        
       
    }
    
}
