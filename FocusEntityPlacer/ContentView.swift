//
//  ContentView.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/5.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView : View {
    @State var placementSetting = PlacementSetting()
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all).environmentObject(placementSetting).onTapGesture(count: 1) {
            placementSetting.placeModel = true
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSetting : PlacementSetting
    
    func makeUIView(context: Context) -> CustomARView {

        let arView = CustomARView(frame: .zero)

        placementSetting.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            updateScene(for: arView)
        })
        
        return arView
        
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.foucsEntity?.isEnabled = true
        if placementSetting.placeModel == true {
            if let confirmedModel = placementSetting.confirmedModel, let modelEntity = confirmedModel.modelEntity {
                self.place(modelEntity, in: arView)
                self.placementSetting.placeModel = false
            }
        }
        
    }
    
    private func place(_ modelEntity: ModelEntity, in arView : ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)
        
        clonedEntity.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        arView.scene.addAnchor(anchorEntity)
        
        print("Added modelEntity")
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
