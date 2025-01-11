import SwiftUI

@main
struct PortalApp: App {
    var body: some Scene {
        WindowGroup {
            PortalView()
        }
    }
}

// Add these extensions to help with color conversion
extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        return (Double(r), Double(g), Double(b), Double(o))
    }
}