//
//  PlacementSetting.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/5.
//

import Foundation
import Combine
import ARKit

struct ModelAnchor {
    var model: USDZModel
    var anchor: ARAnchor?
}

class PlacementSetting  : ObservableObject {
    var sceneObserver: Cancellable?
    var modelConfirmedForPlacement: [ModelAnchor] = []
    @Published var selectedModel: USDZModel? {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.modelName))")
        }
    }
    var placeModel : Bool = false
    @Published var readyToPlace : Bool  = true
    @Published var recentlyPlaced: [USDZModel] = []
    
    init() {
        let model = USDZModel(modelName: "hello")
        model.asyncLoadModelEntity { completed, error in
            if completed {
                self.selectedModel = model
            }
        }
        
    }


}
