//
//  ARViewContainer.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/11.
//

import SwiftUI
import RealityKit
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSetting : PlacementSetting
    @EnvironmentObject var sceneManager : SceneManager
    @EnvironmentObject var modelDeletionManager : ModelDeletionManager


    func makeUIView(context: Context) -> CustomARView {

        let arView = CustomARView(frame: .zero, modelDeletionManager:  modelDeletionManager)
        arView.session.delegate = context.coordinator
        placementSetting.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            self.updateScene(for: arView)
            self.updatePersistenceAvailability(for: arView)
            self.handlePersistence(for: arView)

        })
        
        return arView
        
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.foucsEntity?.isEnabled = placementSetting.readyToPlace
        if let modelAnchor = self.placementSetting.modelConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {

            if let anchor = modelAnchor.anchor {
                // Anchor is being loaded from persisted scene
                self.place(modelEntity, for: anchor, in: arView)
                
//                arView.session.add(anchor: anchor)  // persistence anchor has been added in loadScene
                
//                self.placementSetting.recentlyPlaced.append(modelAnchor.model)
            } else if let transform = getTransformForPlacement(in: arView) {
                // Anchor needs to be created from placement
                let anchorName = anchorNamePrefix + modelAnchor.model.modelName
                let anchor = ARAnchor(name:anchorName, transform: transform)
                
                //self.place(modelEntity, for: anchor, in: arView)  // avoid duplicate placement
                
                arView.session.add(anchor: anchor)
                
                self.placementSetting.recentlyPlaced.append(modelAnchor.model)
            }
        
    }
        
        
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView : ARView) {
//        let clonedEntity = modelEntity.clone(recursive: true)
//
//        clonedEntity.generateCollisionShapes(recursive: true)
//
//        arView.installGestures([.translation, .rotation], for: clonedEntity)
//
//        let anchorEntity = AnchorEntity(plane: .any)
//        anchorEntity.addChild(clonedEntity)
        
//        guard let anchorEntity = try? DOET.loadCart() else {
//            print("Error: can not load doet")
//            return
//        }
        
//        guard let anchorEntity = try? Animation.load场景() else {
//            print("Error: can not load Animation")
//            return
//        }
        
        guard let anchorEntity = loadRealityComposerScene(filename: "fanfare",
                                 fileExtension: "reality",
                                                          sceneName:"") else {
            print("Error: can not load entity")
            return
        }
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        arView.scene.addAnchor(anchorEntity)

//        self.sceneManager.anchorEntities.append(anchorEntity)
        
        print("Added modelEntity")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any) else {
            return nil
        }
        guard let raycastResult = arView.session.raycast(query).first else {return nil}
        return raycastResult.worldTransform
    }
    
    func createRealityURL(filename: String,
                          fileExtension: String,
                          sceneName:String) -> URL? {
        // Create a URL that points to the specified Reality file.
        guard let realityFileURL = Bundle.main.url(forResource: filename,
                                                   withExtension: fileExtension) else {
            print("Error finding Reality file \(filename).\(fileExtension)")
            return nil
        }

        // Append the scene name to the URL to point to
        // a single scene within the file.
        let realityFileSceneURL = realityFileURL.appendingPathComponent(sceneName,
                                                                        isDirectory: false)
        return realityFileSceneURL
    }
    
    func loadRealityComposerScene(filename: String,
                                    fileExtension: String,
                                    sceneName: String) -> (Entity & HasAnchoring)? {
        guard let realitySceneURL = createRealityURL(filename: filename,
                                                     fileExtension: fileExtension,
                                                     sceneName: sceneName) else {
            return nil
        }
        let loadedAnchor = try? Entity.loadAnchor(contentsOf: realitySceneURL)
        
        return loadedAnchor
    }
}

extension ARViewContainer {
    private func updatePersistenceAvailability(for arView: ARView) {
        guard let currentFrame = arView.session.currentFrame else {
            print("ARFrame not available.")
            return
        }
        switch currentFrame.worldMappingStatus {
        case.mapped,.extending:
            self.sceneManager.isPersistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.isPersistenceAvailable = false
        }
    }
    
    private func handlePersistence(for arView:  CustomARView) {
        if self.sceneManager.shouldSaveSceneToFilesystem {
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
            self.sceneManager.shouldSaveSceneToFilesystem = false
        } else if self.sceneManager.shouldLoadSceneFromFilesystem {
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                print("Unable to retrieve scenePersistenceData. Canceled load Scene operation")
                self.sceneManager.shouldLoadSceneFromFilesystem = false
                return
            }
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            self.sceneManager.shouldLoadSceneFromFilesystem = false
        }
    }
}

extension ARViewContainer {
    class Coordinator : NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    print("ARSession: didAdd anchor for modelName: \(modelName)")

                    let model = USDZModel(modelName: String(modelName))

                    model.asyncLoadModelEntity { completed, error in
                        if completed {
                            let modelAnchor = ModelAnchor(model:model, anchor: anchor)
                            self.parent.placementSetting.modelConfirmedForPlacement.append(modelAnchor)
                            print("(\(self.parent.placementSetting.modelConfirmedForPlacement.count)) Adding modelAnchor with name: \(model.modelName)")
                        }
                    }

                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
