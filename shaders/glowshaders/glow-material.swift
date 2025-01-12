import RealityKit
import Metal

/**

# Add to your project's build settings:

1. In Xcode, select your project in the navigator
2. Select your target
3. Select "Build Settings" tab
4. Add these settings:

# Metal Compiler Build Settings
MTL_COMPILER_FLAGS = -fno-fast-math
MTL_LANGUAGE_REVISION = Metal30
MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE

# Custom Metal Library
METAL_LIBRARY_OUTPUT_DIR = $(TARGET_BUILD_DIR)
METAL_LIBRARY_PATH = $(METAL_LIBRARY_OUTPUT_DIR)/default.metallib

# Add build phase for Metal shaders:
1. Select your target
2. Click "+" under "Build Phases"
3. Add "New Build Phase" -> "New Run Script Phase"
4. Add this script:

```bash
# Compile Metal shaders
xcrun metal -c "${SRCROOT}/YourProject/Shaders/GlowShader.metal" \
    -o "${DERIVED_FILE_DIR}/GlowShader.air"

# Create Metal library
xcrun metallib -o "${METAL_LIBRARY_OUTPUT_DIR}/default.metallib" \
    "${DERIVED_FILE_DIR}/GlowShader.air"
```

*/
import RealityKit

struct GlowParameters {
    var intensity: Float
    var color: SIMD4<Float>
    var radius: Float
    var falloff: Float
    
    static let `default` = GlowParameters(
        intensity: 2.0,
        color: [1.0, 0.5, 0.0, 1.0], // Orange glow
        radius: 1.0,
        falloff: 3.0
    )
}

class GlowMaterial {
    private var material: ShaderMaterial
    
    init(parameters: GlowParameters = .default) throws {
        // Create descriptor for the material
        let materialDescriptor = ShaderMaterial.Descriptor(
            name: "GlowMaterial",
            surface: .init(
                outputs: [
                    .init(name: "color", 
                          property: .color,
                          semantic: .color,
                          fragment: .init(name: "glow_fragment"))
                ],
                vertex: .init(name: "glow_vertex"),
                fragment: .init(name: "glow_fragment"),
                lighting: .unlit
            )
        )

        let shaderFunction = """
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
            float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
            out.position = uniforms.viewProjectionMatrix * worldPosition;
            out.worldPosition = worldPosition.xyz;
            out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
            out.uv = in.uv;
            return out;
        }

        fragment float4 glow_fragment(VertexOut in [[stage_in]],
                                    constant GlowUniforms& uniforms [[buffer(0)]]) {
            float3 normal = normalize(in.worldNormal);
            float3 viewDirection = normalize(uniforms.cameraPosition - in.worldPosition);
            
            // Calculate fresnel effect for edge glow
            float fresnel = 1.0 - max(dot(normal, viewDirection), 0.0);
            fresnel = pow(fresnel, uniforms.falloff) * uniforms.intensity;
            
            // Calculate radial glow
            float2 centeredUV = in.uv - 0.5;
            float radialGlow = length(centeredUV) * uniforms.radius;
            radialGlow = 1.0 - smoothstep(0.0, 1.0, radialGlow);
            
            // Combine effects
            float glowFactor = mix(fresnel, radialGlow, 0.5);
            
            // Final color with glow
            float4 finalColor = uniforms.color;
            finalColor.rgb += glowFactor * uniforms.color.rgb * uniforms.intensity;
            
            return finalColor;
        }
        """
        
        // Create the material
        material = try ShaderMaterial(
            descriptor: materialDescriptor,
            functions: [
                .init(name: "glow_vertex", source: shaderFunction),
                .init(name: "glow_fragment", source: shaderFunction)
            ],
            parameters: [
                "intensity": .init(value: .float(parameters.intensity)),
                "color": .init(value: .float4(parameters.color)),
                "radius": .init(value: .float(parameters.radius)),
                "falloff": .init(value: .float(parameters.falloff))
            ]
        )
    }
    
    func getMaterial() -> ShaderMaterial {
        return material
    }
    
    func updateParameters(_ parameters: GlowParameters) {
        material.setParameter(name: "intensity", value: .float(parameters.intensity))
        material.setParameter(name: "color", value: .float4(parameters.color))
        material.setParameter(name: "radius", value: .float(parameters.radius))
        material.setParameter(name: "falloff", value: .float(parameters.falloff))
    }
}