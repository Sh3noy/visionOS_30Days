import RealityKit
import ShaderGraph

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

class GlowMaterial {
    private let material: ShaderMaterial
    
    init(parameters: GlowMaterialParameters = .default) throws {
        let descriptor = ShaderMaterialDescriptor(
            name: "GlowMaterial",
            surfaces: [
                .unlit: ShaderSurface(
                    vertex: .custom("glow_vertex"),
                    fragment: .custom("glow_fragment")
                )
            ],
            parameters: [
                "glowIntensity": .float(parameters.intensity),
                "glowColor": .float4(parameters.color),
                "glowRadius": .float(parameters.radius),
                "glowFalloff": .float(parameters.falloff)
            ]
        )
        
        // Load shader source from GlowShader.metal file
        guard let shaderURL = Bundle.main.url(forResource: "GlowShader", withExtension: "metal"),
              let shaderSource = try? String(contentsOf: shaderURL, encoding: .utf8) else {
            throw GlowMaterialError.shaderNotFound
        }
        
        material = try ShaderMaterial(descriptor: descriptor, functionSource: shaderSource)
    }
    
    func getMaterial() -> ShaderMaterial {
        return material
    }
    
    func updateParameters(_ parameters: GlowMaterialParameters) {
        material.setParameter("glowIntensity", value: .float(parameters.intensity))
        material.setParameter("glowColor", value: .float4(parameters.color))
        material.setParameter("glowRadius", value: .float(parameters.radius))
        material.setParameter("glowFalloff", value: .float(parameters.falloff))
    }
}

enum GlowMaterialError: Error {
    case shaderNotFound
}