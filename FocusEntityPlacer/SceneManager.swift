//
//  SceneManagerViewModel.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/11.
//

import Foundation
import RealityKit

class SceneManager: ObservableObject {
    @Published var isPersistenceAvailable : Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    
    var shouldSaveSceneToFilesystem: Bool = false
    var shouldLoadSceneFromFilesystem: Bool = false
    
    lazy var persistenceUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor : nil, create : true).appendingPathComponent("arf.persistence")
        } catch {
            fatalError("Unable to get persistenceUrl \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData : Data? {
        return try? Data(contentsOf: persistenceUrl)
    }
}
