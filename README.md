FocusEntityPlacer

## Description
A ios application for model placment based on swiftui and realitykit.

## Dependencies
* ios >= 15.0
* [FocusEntity](https://github.com/maxxfrazer/FocusEntity)

## Usage
modify the object name in function `init()` of `PlacementSetting.swift` to expected model.
```swift
    init() {
      self.selectedModel = USDZModel(modelName: "crown.reality")  // modify the model name here
      self.selectedModel?.asyncLoadModelEntity { completed, error in
       if completed {}
       }
        
    }

```