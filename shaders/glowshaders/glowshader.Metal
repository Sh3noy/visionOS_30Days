#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

struct GlowVertexUniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
};

struct GlowFragmentUniforms {
    float intensity;
    float4 color;
    float radius;
    float falloff;
    float3 cameraPosition;
};

[[visible]]
void glow_vertex(realitykit::vertex_parameters params) {
    params.geometry();
}

[[visible]]
void glow_fragment(realitykit::fragment_parameters params) {
    auto surface = params.surface();
    
    // Get custom parameters
    float intensity = params.uniforms().custom().intensity;
    float4 glowColor = params.uniforms().custom().color;
    float radius = params.uniforms().custom().radius;
    float falloff = params.uniforms().custom().falloff;
    
    // Calculate view direction
    float3 worldNormal = normalize(params.geometry().world_normal());
    float3 viewDirection = normalize(params.uniforms().world_camera_position() - 
                                  params.geometry().world_position());
    
    // Calculate fresnel effect
    float fresnel = 1.0 - max(dot(worldNormal, viewDirection), 0.0);
    fresnel = pow(fresnel, falloff) * intensity;
    
    // Calculate radial glow
    float2 uv = params.geometry().uv0();
    float radialGlow = length(uv - 0.5) * radius;
    radialGlow = 1.0 - smoothstep(0.0, 1.0, radialGlow);
    
    // Combine effects
    float glowFactor = mix(fresnel, radialGlow, 0.5);
    
    // Set final color
    half4 finalColor = half4(glowColor);
    finalColor.rgb += glowFactor * glowColor.rgb;
    
    surface.set_base_color(finalColor);
    surface.set_roughness(0.0h);
    surface.set_metallic(0.0h);
    surface.set_opacity(finalColor.a);
}