//
//  CustomARView.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/5.
//

import RealityKit
import Foundation
import FocusEntity
import ARKit

class CustomARView: ARView {
    
    var foucsEntity : FocusEntity?
    var modelDeletionManager : ModelDeletionManager
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        return config
    }
    
    required init(frame frameRect: CGRect, modelDeletionManager : ModelDeletionManager) {
        self.modelDeletionManager = modelDeletionManager

        super.init(frame: frameRect)
        self.foucsEntity = FocusEntity(on: self, focus: .classic)
        self.configure()
        self.enableObjectDeletion()
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        session.run(defaultConfiguration)
    }
    
}

extension CustomARView {
    func enableObjectDeletion() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(recognizer : UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        if let entity = self.entity(at: location) as? ModelEntity {
            modelDeletionManager.entitySelectedForDeletion = entity
        }
    }
}
