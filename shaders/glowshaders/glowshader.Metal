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
    float3 worldNormal;
    float2 uv;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3 cameraPosition;
    float glowIntensity;
    float4 glowColor;
    float glowRadius;
    float glowFalloff;
};

vertex VertexOut glow_vertex(VertexIn in [[stage_in]],
                            constant Uniforms& uniforms [[buffer(0)]]) {
    VertexOut out;
    
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.worldPosition = worldPosition.xyz;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
    out.uv = in.uv;
    
    return out;
}

fragment float4 glow_fragment(VertexOut in [[stage_in]],
                            constant Uniforms& uniforms [[buffer(0)]]) {
    float3 normal = normalize(in.worldNormal);
    float3 viewDirection = normalize(uniforms.cameraPosition - in.worldPosition);
    
    // Enhanced Fresnel effect
    float fresnel = 1.0 - max(dot(normal, viewDirection), 0.0);
    fresnel = pow(fresnel, uniforms.glowFalloff) * uniforms.glowIntensity;
    
    // Radial glow
    float radialGlow = length(in.uv - 0.5) * uniforms.glowRadius;
    radialGlow = 1.0 - smoothstep(0.0, 1.0, radialGlow);
    
    // Combine effects
    float glowFactor = mix(fresnel, radialGlow, 0.5);
    
    // Final color with glow
    float4 finalColor = uniforms.glowColor;
    finalColor.rgb += uniforms.glowColor.rgb * glowFactor;
    
    return finalColor;
}