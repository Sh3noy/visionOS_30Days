import SwiftUI
import RealityKit

struct GlowObjectView: View {
    let mesh: MeshResource
    @Binding var parameters: GlowParameters
    
    @State private var glowMaterial: GlowMaterial?
    
    var body: some View {
        RealityView { content in
            // Create material and entity
            do {
                let material = try GlowMaterial(parameters: parameters)
                let entity = ModelEntity(mesh: mesh, materials: [material.getMaterial()])
                content.add(entity)
                
                glowMaterial = material
            } catch {
                print("Failed to create glow material: \(error)")
            }
        } update: { _ in
            // Update material parameters
            glowMaterial?.updateParameters(parameters)
        }
    }
}

struct GlowControls: View {
    @Binding var parameters: GlowParameters
    
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
                
                ColorPicker("Glow Color", selection: Binding(
                    get: { Color(red: Double(parameters.color.x),
                               green: Double(parameters.color.y),
                               blue: Double(parameters.color.z),
                               opacity: Double(parameters.color.w)) },
                    set: { newColor in
                        if let components = try? newColor.cgColor?.components {
                            parameters.color = SIMD4<Float>(
                                Float(components[0]),
                                Float(components[1]),
                                Float(components[2]),
                                Float(components[3])
                            )
                        }
                    }
                ))
            }
        }
        .formStyle(.grouped)
        .frame(width: 320)
        .padding()
    }
}

// Example usage
struct ContentView: View {
    @State private var parameters = GlowParameters.default
    
    var body: some View {
        HStack {
            GlowObjectView(
                mesh: .generateSphere(radius: 0.1),
                parameters: $parameters
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GlowControls(parameters: $parameters)
        }
    }
}