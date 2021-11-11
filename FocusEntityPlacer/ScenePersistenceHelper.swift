//
//  ScenePersistenceHelper.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/11.
//

import Foundation
import RealityKit
import ARKit

class ScenePersistenceHelper {
    // ARKit saves the state of the scene and any ARAnchors in the scene.
    // ARKit does not save any models or anchor entities.
    // So whenever we load a scene from file, we will use the model and ARAnchor pair for placement.
    class func saveScene(for arView: CustomARView, at persistenceUrl: URL) {
        print("Save scene to local filesystem.")
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Persistence Error: Unable to get worldMap : \(error!.localizedDescription)")
                return
            }
            
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try sceneData.write(to: persistenceUrl, options: [.atomic])
            } catch {
                print("Persistence Error: Can't save scene to local filesystem: \(error.localizedDescription)")
            }
        }
    }
    
    class func loadScene(for arView: CustomARView, with scenePersistenceData: Data) {
        print("Load scene from local filesystem.")
        
        let worldMap: ARWorldMap = {
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    fatalError("Persistence Error : No ARWorldMap in archive.")
                }
                return worldMap
            } catch {
                fatalError("Persistence Error: Can't unarchinve ARWorldMap from scenePersistenceData: \(error.localizedDescription)")
            }
        }()
        
        let newConfig = arView.defaultConfiguration
        newConfig.initialWorldMap = worldMap
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
}
