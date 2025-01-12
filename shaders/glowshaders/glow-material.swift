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
    private var material: Material
    private var shader: MaterialShader
    
    init(parameters: GlowParameters = .default) throws {
        // Create material shader
        shader = try MaterialShader(named: "glow")
        
        // Create material descriptor
        var descriptor = Material.Descriptor()
        descriptor.lightingModel = .unlit
        descriptor.shaderModifier = shader

        // Create material with shader
        material = try .init(descriptor)
        
        // Set initial parameters
        updateParameters(parameters)
    }
    
    func getMaterial() -> Material {
        return material
    }
    
    func updateParameters(_ parameters: GlowParameters) {
        try? material.setParameter("intensity", value: .float(parameters.intensity))
        try? material.setParameter("color", value: .float4(parameters.color))
        try? material.setParameter("radius", value: .float(parameters.radius))
        try? material.setParameter("falloff", value: .float(parameters.falloff))
    }
}