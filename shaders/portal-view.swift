import SwiftUI
import RealityKit

struct PortalView: View {
    @State private var parameters = PortalSkyboxParameters.default
    @State private var portalSkybox: PortalSkybox?
    
    var body: some View {
        ZStack {
            // Main 3D view
            RealityView { content in
                // Load skybox texture
                guard let textureResource = try? TextureResource.load(named: "skybox") else {
                    return
                }
                
                // Create and add portal skybox
                do {
                    let skybox = try PortalSkybox(skyboxTexture: textureResource)
                    skybox.addToScene(content)
                    portalSkybox = skybox
                } catch {
                    print("Failed to create portal skybox: \(error)")
                }
            } update: { content in
                // Update portal parameters
                portalSkybox?.update(parameters: parameters)
            }
            
            // Controls overlay
            VStack {
                Spacer()
                
                // Portal controls
                PortalControls(parameters: $parameters)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding()
            }
        }
    }
}

struct PortalControls: View {
    @Binding var parameters: PortalSkyboxParameters
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Portal Controls")
                .font(.headline)
            
            VStack {
                Text("Dissolve Progress")
                Slider(value: $parameters.dissolveProgress, in: 0...1)
            }
            
            VStack {
                Text("Noise Scale")
                Slider(value: $parameters.noiseScale, in: 0.1...5)
            }
            
            VStack {
                Text("Edge Width")
                Slider(value: $parameters.edgeWidth, in: 0...0.2)
            }
            
            ColorPicker("Portal Color", selection: Binding(
                get: {
                    Color(.sRGB,
                         red: Double(parameters.portalColor.x),
                         green: Double(parameters.portalColor.y),
                         blue: Double(parameters.portalColor.z),
                         opacity: Double(parameters.portalColor.w))
                },
                set: { newColor in
                    let components = newColor.components
                    parameters.portalColor = SIMD4<Float>(
                        Float(components.red),
                        Float(components.green),
                        Float(components.blue),
                        Float(components.opacity)
                    )
                }
            ))
        }
        .padding()
        .frame(width: 300)
    }
}