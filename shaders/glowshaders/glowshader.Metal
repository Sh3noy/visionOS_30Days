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

struct GlowUniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3 cameraPosition;
    float intensity;
    float4 color;
    float radius;
    float falloff;
};

vertex VertexOut glow_vertex(VertexIn in [[stage_in]],
                           constant GlowUniforms& uniforms [[buffer(0)]]) {
    VertexOut out;
    
    // Transform position
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    
    // Pass through world-space data
    out.worldPosition = worldPosition.xyz;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
    out.uv = in.uv;
    
    return out;
}

fragment float4 glow_fragment(VertexOut in [[stage_in]],
                            constant GlowUniforms& uniforms [[buffer(0)]]) {
    // Normalize vectors
    float3 normal = normalize(in.worldNormal);
    float3 viewDirection = normalize(uniforms.cameraPosition - in.worldPosition);
    
    // Calculate fresnel effect for edge glow
    float fresnel = 1.0 - max(dot(normal, viewDirection), 0.0);
    fresnel = pow(fresnel, uniforms.falloff) * uniforms.intensity;
    
    // Calculate radial glow based on UV distance from center
    float2 centeredUV = in.uv - 0.5;
    float radialGlow = length(centeredUV) * uniforms.radius;
    radialGlow = 1.0 - smoothstep(0.0, 1.0, radialGlow);
    
    // Combine glow effects
    float glowFactor = mix(fresnel, radialGlow, 0.5);
    
    // Apply color and glow
    float4 finalColor = uniforms.color;
    finalColor.rgb += glowFactor * uniforms.color.rgb;
    
    // Add extra emission for the glow effect
    finalColor.rgb += glowFactor * uniforms.color.rgb * uniforms.intensity;
    
    return finalColor;
}