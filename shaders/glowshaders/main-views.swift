import SwiftUI
import RealityKit

// MARK: - Main View
struct ContentView: View {
    @State private var parameters = GlowMaterialParameters.default
    
    var body: some View {
        HStack {
            GlowObject(
                mesh: .generateSphere(radius: 0.1),
                parameters: $parameters
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GlowControls(parameters: $parameters)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}