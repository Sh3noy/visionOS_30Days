import RealityKit
import Metal

struct GlowMaterialParameters {
    var intensity: Float
    var color: SIMD4<Float>
    var radius: Float
    var falloff: Float
    
    static let `default` = GlowMaterialParameters(
        intensity: 2.0,
        color: [1.0, 0.5, 0.0, 1.0],
        radius: 1.0,
        falloff: 3.0
    )
}

enum GlowMaterialError: Error {
    case shaderNotFound
    case failedToLoadShader
}

class GlowMaterial {
    private var material: CustomMaterial
    
    init(parameters: GlowMaterialParameters = .default) throws {
        // Load shader code from Metal file
        guard let shaderURL = Bundle.main.url(forResource: "GlowShader", withExtension: "metal") else {
            throw GlowMaterialError.shaderNotFound
        }
        
        let shaderSource: String
        do {
            shaderSource = try String(contentsOf: shaderURL, encoding: .utf8)
        } catch {
            throw GlowMaterialError.failedToLoadShader
        }
        
        // Create custom material
        material = try CustomMaterial(
            name: "GlowMaterial",
            librarySource: shaderSource,
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
    
    func updateParameters(_ parameters: GlowMaterialParameters) {
        material.setParameter("intensity", value: .float(parameters.intensity))
        material.setParameter("color", value: .float4(parameters.color))
        material.setParameter("radius", value: .float(parameters.radius))
        material.setParameter("falloff", value: .float(parameters.falloff))
    }
}

// Helper to ensure shader file is included in bundle
extension Bundle {
    var metalLibURL: URL? {
        url(forResource: "default", withExtension: "metallib")
    }
}