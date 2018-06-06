import Foundation
import Metal
import simd

class BufferProvider: NSObject {
   
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var vertexBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0
    private var avaliableVertexBufferIndex: Int = 0
    var avaliableResourcesSemaphore: DispatchSemaphore
    
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int, sizeOfVertexBuffer: Int ) {
        
        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        vertexBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer)
            
            let vertexBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            vertexBuffers.append(vertexBuffer)
            
        }
    }
    
    func nextUniformsBuffer(modelViewMatrix: float4x4) -> MTLBuffer {
        
       
        let buffer = uniformsBuffers[avaliableBufferIndex]
     
        let bufferPointer = buffer.contents()
        var modelViewMatrix = modelViewMatrix
      
       // memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * float4x4.numberOfElements())
        memcpy(bufferPointer, &modelViewMatrix, MemoryLayout<Float>.size*float4x4.numberOfElements())
       
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
            avaliableBufferIndex = 0
        }
        
        return buffer
    }
    
    func nextVertexBuffer(verticesArray: Array<Float>) -> MTLBuffer {
        
        
        let buffer = vertexBuffers[avaliableVertexBufferIndex]
       
        let bufferPointer = buffer.contents()
        var vertexData = verticesArray
        
        // memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * float4x4.numberOfElements())
         let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        memcpy(bufferPointer, &vertexData, dataSize)
        
        avaliableVertexBufferIndex += 1
        if avaliableVertexBufferIndex == inflightBuffersCount{
            avaliableVertexBufferIndex = 0
        }
        
        return buffer
    }
    
    deinit{
        for _ in 0...self.inflightBuffersCount{
            self.avaliableResourcesSemaphore.signal()
        }
    }
}
