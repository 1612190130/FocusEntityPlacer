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
    @State private var selectedControlMode : Int = 0
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all).environmentObject(placementSetting)
                .environmentObject(sceneManager)
                .onTapGesture(count: 1) {
                placementSetting.readyToPlace.toggle()
                
            }
            VStack {
                Spacer()
                if self.placementSetting.readyToPlace == false {
                    ControlView(selectedControlMode: $selectedControlMode).environmentObject(sceneManager)
                } else {
                    Button("Place") {
                        
                        let modelAnchor = ModelAnchor(model:self.placementSetting.selectedModel!, anchor: nil)
                        self.placementSetting.modelConfirmedForPlacement.append(modelAnchor)
//                        self.placementSetting.selectedModel = nil
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .font(.headline)
                    
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
