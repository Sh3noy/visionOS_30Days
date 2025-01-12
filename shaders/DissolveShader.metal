#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

// Improved noise function for smooth transitions
float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 permute(float3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(float2 v) {
    const float4 C = float4(0.211324865405187, 0.366025403784439,
                           -0.577350269189626, 0.024390243902439);
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v -   i + dot(i, C.xx);
    float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
    float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m; m = m*m;
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

[[visible]]
void portal_vertex(realitykit::vertex_parameters params) {
    params.geometry();
}

[[visible]]
void portal_fragment(realitykit::fragment_parameters params) {
    auto surface = params.surface();
    
    // Get custom parameters
    float transitionProgress = params.uniforms().custom().transitionProgress;
    float4 portalColor = params.uniforms().custom().portalColor;
    float noiseScale = params.uniforms().custom().noiseScale;
    float edgeWidth = params.uniforms().custom().edgeWidth;
    float portalRadius = params.uniforms().custom().portalRadius;
    
    // Calculate spherical coordinates for position-based effects
    float3 pos = normalize(params.geometry().world_position());
    float2 sphericalCoords = float2(
        atan2(pos.z, pos.x),  // azimuth
        acos(pos.y)           // inclination
    );
    
    // Generate noise for portal edge
    float2 noiseInput = sphericalCoords * noiseScale;
    float noise = snoise(noiseInput) * 0.5 + 0.5;
    
    // Calculate distance from portal center (in spherical coordinates)
    float2 portalCenter = float2(3.14159, 1.5708); // Center of the sphere
    float distanceToPortal = length(sphericalCoords - portalCenter) * portalRadius;
    
    // Combine noise with distance for organic portal shape
    float portalMask = smoothstep(0.0, 1.0, distanceToPortal + noise * 0.3);
    
    // Calculate edge glow
    float edge = smoothstep(transitionProgress - edgeWidth, 
                          transitionProgress, 
                          portalMask);
    edge *= 1.0 - smoothstep(transitionProgress, 
                            transitionProgress + edgeWidth, 
                            portalMask);
    
    // Sample both skybox textures
    half4 skybox1Color = params.uniforms().custom().skybox1Color;
    half4 skybox2Color = params.uniforms().custom().skybox2Color;
    
    // Mix skyboxes based on portal mask and transition
    float transitionFactor = smoothstep(transitionProgress - edgeWidth,
                                      transitionProgress + edgeWidth,
                                      portalMask);
    
    half4 finalColor = mix(skybox1Color, skybox2Color, transitionFactor);
    
    // Add portal edge glow
    finalColor.rgb += edge * half3(portalColor.rgb) * 2.0h;
    
    surface.set_base_color(finalColor);
    surface.set_emissive(edge * half3(portalColor.rgb) * 3.0h);
    surface.set_roughness(0.0h);
    surface.set_metallic(0.0h);
}