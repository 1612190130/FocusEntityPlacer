//
//  USDZModel.swift
//  FirstARKitDemo
//
//  Created by baochong on 2021/10/21.
//
import UIKit
import Foundation
import RealityKit
import Combine

class USDZModel{
    var modelName: String
    var modelEntity: Entity?
    private var cancellable: AnyCancellable? = nil
    
    
    init(modelName: String){
        self.modelName = modelName
//        let fileName = self.modelName+".usdz"
//        self.cancellable = ModelEntity.loadModelAsync(named: fileName)
//            .sink(receiveCompletion : {loadCompletion in
//                print("1")
//            }, receiveValue:{modelEntity in
//                self.modelEntity = modelEntity
//            })
    }
    
    func asyncLoadModelEntity(handler : @escaping(_ completed : Bool, _ error: Error?)->Void) {
        let fileNameArr = self.modelName.components(separatedBy: ".")
        guard let url = createRealityURL(filename: fileNameArr[0], fileExtension: fileNameArr[1], sceneName: "") else {
            print("Warnning: can not create url \(self.modelName)")
            return
        }
        self.cancellable = Entity.loadAsync(contentsOf: url)
            .sink(receiveCompletion : {loadCompletion in
                if case let .failure(error) = loadCompletion {
                    print("Error: can not load \(url.description)")
                    handler(false,error)
                }
            }, receiveValue:{modelEntity in
                
                handler(true,nil)
                self.modelEntity = modelEntity
            })
    }
    
    func loadRealityComposerScene (filename: String,
                                    fileExtension: String,
                                    sceneName: String) -> (AnchorEntity)? {
        guard let realitySceneURL = createRealityURL(filename: filename,
                                                     fileExtension: fileExtension,
                                                     sceneName: sceneName) else {
            return nil
        }
        let loadedAnchor = try? Entity.loadAnchor(contentsOf: realitySceneURL)
        
        return loadedAnchor
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
        print("realityFileSceneURL.url : \(realityFileURL.description)")
        return realityFileSceneURL
    }
}
