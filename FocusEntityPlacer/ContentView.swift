//
//  ContentView.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/5.
//

import SwiftUI
import Combine

struct ContentView : View {
    @StateObject var placementSetting = PlacementSetting()
    @StateObject var sceneManager = SceneManager()
    @StateObject var modelDeletionManager = ModelDeletionManager()

    @State private var selectedControlMode : Int = 0
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
                .environmentObject(placementSetting)
                .environmentObject(sceneManager)
                .environmentObject(modelDeletionManager)
                .onTapGesture(count: 1) {
                //placementSetting.readyToPlace.toggle()
                
            }
            VStack {
                Spacer()
                if self.placementSetting.readyToPlace == true {
                    Button("Place") {
                        if let selectModel = self.placementSetting.selectedModel {
                            let modelAnchor = ModelAnchor(model: selectModel, anchor: nil)
                            self.placementSetting.modelConfirmedForPlacement.append(modelAnchor)
                        } else {
                            print("Error: \(self.placementSetting.selectedModel?.modelName) are not ready")
                        }
                       
//                        self.placementSetting.selectedModel = nil
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .font(.headline)
                    
                } else if self.modelDeletionManager.entitySelectedForDeletion != nil {
                    DeletionView().environmentObject(sceneManager).environmentObject(modelDeletionManager)
                } else {
                    ControlView(selectedControlMode: $selectedControlMode)
                        .environmentObject(sceneManager)
                        .environmentObject(placementSetting)

                }
            }.padding(.bottom)
            
        }.edgesIgnoringSafeArea(.all)
        
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
