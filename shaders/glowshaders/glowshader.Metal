#include <metal_stdlib>
using namespace metal;

[[visible]]
void glow_vertex(float3 position [[attribute(0)]],
                float3 normal [[attribute(1)]],
                float2 uv [[attribute(2)]],
                float4x4 modelMatrix [[buffer(0)]],
                float4x4 viewProjectionMatrix [[buffer(1)]],
                device const float3& cameraPosition [[buffer(2)]],
                device float4& out_position [[buffer(3)]],
                device float3& out_worldPosition [[buffer(4)]],
                device float3& out_worldNormal [[buffer(5)]],
                device float2& out_uv [[buffer(6)]]) {
    float4 worldPosition = modelMatrix * float4(position, 1.0);
    out_position = viewProjectionMatrix * worldPosition;
    out_worldPosition = worldPosition.xyz;
    out_worldNormal = (modelMatrix * float4(normal, 0.0)).xyz;
    out_uv = uv;
}

[[visible]]
void glow_fragment(float3 worldPosition,
                  float3 worldNormal,
                  float2 uv,
                  float3 cameraPosition [[buffer(0)]],
                  float intensity [[buffer(1)]],
                  float4 color [[buffer(2)]],
                  float radius [[buffer(3)]],
                  float falloff [[buffer(4)]],
                  device float4& out_color [[buffer(5)]]) {
    // Calculate view direction
    float3 normal = normalize(worldNormal);
    float3 viewDirection = normalize(cameraPosition - worldPosition);
    
    // Calculate fresnel-based edge glow
    float fresnel = 1.0 - max(dot(normal, viewDirection), 0.0);
    fresnel = pow(fresnel, falloff) * intensity;
    
    // Calculate radial glow
    float2 centeredUV = uv - 0.5;
    float radialGlow = length(centeredUV) * radius;
    radialGlow = 1.0 - smoothstep(0.0, 1.0, radialGlow);
    
    // Combine effects
    float glowFactor = mix(fresnel, radialGlow, 0.5);
    
    // Set final color with glow
    out_color = color;
    out_color.rgb += glowFactor * color.rgb * intensity;
}