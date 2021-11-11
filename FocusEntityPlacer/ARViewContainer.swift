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

    func makeUIView(context: Context) -> CustomARView {

        let arView = CustomARView(frame: .zero)
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
                
                arView.session.add(anchor: anchor)
                
                self.placementSetting.recentlyPlaced.append(modelAnchor.model)
            } else if let transform = getTransformForPlacement(in: arView) {
                // Anchor needs to be created from placement
                let anchorName = anchorNamePrefix + modelAnchor.model.modelName
                let anchor = ARAnchor(name:anchorName, transform: transform)
                
                self.place(modelEntity, for: anchor, in: arView)
                
                arView.session.add(anchor: anchor)
                
                self.placementSetting.recentlyPlaced.append(modelAnchor.model)
            }
        
    }
        
        
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView : ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)
        
        clonedEntity.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        anchorEntity.anchoring = AnchoringComponent(anchor)
        arView.scene.addAnchor(anchorEntity)
        
        self.sceneManager.anchorEntities.append(anchorEntity)
        
        print("Added modelEntity")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any) else {
            return nil
        }
        guard let raycastResult = arView.session.raycast(query).first else {return nil}
        return raycastResult.worldTransform
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
