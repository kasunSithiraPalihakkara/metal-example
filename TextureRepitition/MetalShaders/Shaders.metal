
#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};
struct Uniforms{
    float4x4 modelMatrix;
};
vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms    [[ buffer(1) ]],
                              constant vector_uint2 *viewportSizePointer  [[ buffer(2) ]],
                              unsigned int vid [[ vertex_id ]]) {

    float4x4 mv_Matrix = uniforms.modelMatrix;
    VertexIn VertexIn = vertex_array[vid];

     VertexOut VertexOut;
    //-
     float3 viewportSize = float3(float2(*viewportSizePointer),1);
     VertexIn.position = vertex_array[vid].position/(viewportSize/2.0);
     VertexIn.texCoord = VertexIn.texCoord/(float2(*viewportSizePointer)/2.0);
    //-

    VertexOut.position = mv_Matrix * float4(VertexIn.position,1);
    VertexOut.color = VertexIn.color;
    VertexOut.texCoord = VertexIn.texCoord;
    return VertexOut;
}

//fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {
//    return half4(interpolated.color);
//}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                               float2 uv[[point_coord]],
                               texture2d<float>  tex2D     [[ texture(0) ]],
                               sampler           sampler2D [[ sampler(0) ]]) {


   //float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
    float4 color =  interpolated.color * tex2D.sample(sampler2D, interpolated.texCoord);

  return color;

}

