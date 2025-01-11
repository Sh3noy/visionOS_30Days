import RealityKit
import SwiftUI

struct PortalSkyboxParameters {
    var dissolveProgress: Float = 0.0
    var portalColor: SIMD4<Float> = [0.0, 0.5, 1.0, 1.0]
    var noiseScale: Float = 1.0
    var edgeWidth: Float = 0.1
    
    static let `default` = PortalSkyboxParameters()
}

class PortalSkybox {
    private var skyboxEntity: ModelEntity
    private var dissolveEntity: ModelEntity
    private var material: CustomMaterial
    
    init(skyboxTexture: TextureResource, portalRadius: Float = 5.0) throws {
        // Create skybox sphere
        let skyboxMesh = MeshResource.generateSphere(radius: 50)
        let skyboxMaterial = try TextureMaterial(texture: .init(skyboxTexture))
        skyboxEntity = ModelEntity(mesh: skyboxMesh, materials: [skyboxMaterial])
        
        // Create portal sphere with dissolve shader
        let portalMesh = MeshResource.generateSphere(radius: portalRadius)
        material = try CustomMaterial(surfaceShader: "dissolve_fragment",
                                    geometryModifier: "dissolve_vertex",
                                    lightingModel: .unlit)
        
        dissolveEntity = ModelEntity(mesh: portalMesh, materials: [material])
        
        // Invert skybox normals to render from inside
        skyboxEntity.scale *= .init(x: -1, y: 1, z: 1)
    }
    
    func update(parameters: PortalSkyboxParameters) {
        material.custom.value = parameters
    }
    
    func addToScene(_ scene: RealityKit.Scene) {
        scene.addAnchor(skyboxEntity)
        scene.addAnchor(dissolveEntity)
    }
}