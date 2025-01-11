import SwiftUI
import RealityKit

// MARK: - Controls
struct GlowControls: View {
    @Binding var parameters: GlowMaterialParameters
    
    var body: some View {
        Form {
            Section("Glow Parameters") {
                Slider(value: $parameters.intensity, in: 0...5) {
                    Text("Intensity")
                }
                
                Slider(value: $parameters.radius, in: 0.1...2.0) {
                    Text("Radius")
                }
                
                Slider(value: $parameters.falloff, in: 1.0...5.0) {
                    Text("Falloff")
                }
                
                ColorPicker("Color", selection: Binding(
                    get: { Color(.sRGB,
                               red: Double(parameters.color.x),
                               green: Double(parameters.color.y),
                               blue: Double(parameters.color.z),
                               opacity: Double(parameters.color.w))
                    },
                    set: { newColor in
                        let components = newColor.components
                        parameters.color = SIMD4<Float>(
                            Float(components.red),
                            Float(components.green),
                            Float(components.blue),
                            Float(components.opacity)
                        )
                    }
                ))
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 320)
    }
}

// MARK: - Glow Object
struct GlowObject: View {
    let mesh: MeshResource
    @Binding var parameters: GlowMaterialParameters
    
    private var glowMaterial: GlowMaterial?
    
    init(mesh: MeshResource, parameters: Binding<GlowMaterialParameters>) {
        self.mesh = mesh
        self._parameters = parameters
        
        do {
            self.glowMaterial = try GlowMaterial(parameters: parameters.wrappedValue)
        } catch {
            print("Failed to create glow material: \(error)")
        }
    }
    
    var body: some View {
        RealityView { content in
            guard let material = glowMaterial?.getMaterial() else { return }
            
            let entity = ModelEntity(mesh: mesh, materials: [material])
            content.add(entity)
            
        } update: { content in
            guard let material = glowMaterial else { return }
            material.updateParameters(parameters)
        }
    }
}