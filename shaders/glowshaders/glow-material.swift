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
    private var material: CustomMaterial
    
    init(parameters: GlowParameters = .default) throws {
        // Create custom material
        material = try CustomMaterial(
            surfaceShader: "glow_fragment",
            geometryModifier: "glow_vertex",
            lightingModel: .unlit,
            parameters: [
                "intensity": .float(parameters.intensity),
                "color": .float4(parameters.color),
                "radius": .float(parameters.radius),
                "falloff": .float(parameters.falloff)
            ]
        )
    }
    
    func getMaterial() -> CustomMaterial {
        return material
    }
    
    func updateParameters(_ parameters: GlowParameters) {
        material.setParameter("intensity", value: .float(parameters.intensity))
        material.setParameter("color", value: .float4(parameters.color))
        material.setParameter("radius", value: .float(parameters.radius))
        material.setParameter("falloff", value: .float(parameters.falloff))
    }
}