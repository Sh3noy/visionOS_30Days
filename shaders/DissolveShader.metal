#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float2 uv;
    float3 worldNormal;
};

struct DissolveUniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float dissolveProgress;
    float4 portalColor;
    float noiseScale;
    float edgeWidth;
};

// Noise function for dissolve effect
float noise3D(float3 p) {
    float3 i = floor(p);
    float3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float2 uv = (i.xy + float2(37.0, 17.0) * i.z) + f.xy;
    float2 rg = fract(sin(uv * float2(13.0, 7.0)) * float2(5329.0, 4337.0));
    return mix(rg.x, rg.y, f.z);
}

vertex VertexOut dissolve_vertex(VertexIn in [[stage_in]],
                               constant DissolveUniforms& uniforms [[buffer(0)]]) {
    VertexOut out;
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.worldPosition = worldPosition.xyz;
    out.uv = in.uv;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
    return out;
}

fragment float4 dissolve_fragment(VertexOut in [[stage_in]],
                                constant DissolveUniforms& uniforms [[buffer(0)]],
                                texture2d<float> noiseTexture [[texture(0)]]) {
    // Generate noise value
    float noise = noise3D(in.worldPosition * uniforms.noiseScale);
    
    // Calculate dissolve threshold
    float dissolveThreshold = uniforms.dissolveProgress;
    
    // Edge detection
    float edge = smoothstep(dissolveThreshold - uniforms.edgeWidth, 
                          dissolveThreshold, 
                          noise);
    edge *= 1.0 - smoothstep(dissolveThreshold, 
                            dissolveThreshold + uniforms.edgeWidth, 
                            noise);
    
    // Portal color with edge glow
    float4 finalColor = uniforms.portalColor;
    finalColor.rgb += edge * uniforms.portalColor.rgb * 2.0;
    finalColor.a *= step(dissolveThreshold, noise);
    
    return finalColor;
}