//
//  ControlView.swift
//  FocusEntityPlacer
//
//  Created by baochong on 2021/11/11.
//

import SwiftUI

enum ControlModes: String, CaseIterable {
    case browse, scene
}

struct ControlView: View {
    @Binding var selectedControlMode : Int
    @EnvironmentObject var sceneManager : SceneManager

    var body : some View {
        VStack {
            ControlModePicker(selectedControlMode: $selectedControlMode)
            ControlButtonBar(selectedControlMode: selectedControlMode).environmentObject(sceneManager)
        }
    }
}

struct ControlModePicker : View {
    @Binding var selectedControlMode :Int
    let controlModes = ControlModes.allCases
    
    init(selectedControlMode : Binding<Int>) {
        self._selectedControlMode = selectedControlMode
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(displayP3Red: 1.0, green: 0.827, blue: 0, alpha: 1)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.black.opacity(0.25))
    }
    
    var body: some View {
        Picker(selection: $selectedControlMode, label: Text("Select a Control Mode")) {
            ForEach(0..<controlModes.count) { index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: 400)
        .padding(.horizontal, 10)
    }
}

struct ControlButtonBar: View {

    var selectedControlMode : Int
    @EnvironmentObject var sceneManager : SceneManager

    var body: some View {
        HStack(alignment: .center) {
            if selectedControlMode == 1 {
                SceneButtons().environmentObject(sceneManager)
            } else {
                BrowserButtons()
            }
        }
        .frame(maxWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct BrowserButtons: View {
    
    var body: some View {
        ControlButton(systemIconName: "clock.fill") {
            print("Save clock button pressed.")
        }
        Spacer()
        ControlButton(systemIconName: "square.grid.2x2") {
            print("Save square button pressed.")
        }
        Spacer()
        ControlButton(systemIconName: "slider.horizontal.3") {
            print("Clear slider button pressed.")
        }
       
    }
}

struct SceneButtons: View {
    @EnvironmentObject var sceneManager : SceneManager
    
    var body: some View {
        if self.sceneManager.isPersistenceAvailable == true {
            ControlButton(systemIconName: "icloud.and.arrow.up") {
                print("Save Scene button pressed.")
                self.sceneManager.shouldSaveSceneToFilesystem = true
            }
        }
        Spacer()
        if self.sceneManager.scenePersistenceData != nil {
            ControlButton(systemIconName: "icloud.and.arrow.down") {
                print("Save Scene button pressed.")
                self.sceneManager.shouldLoadSceneFromFilesystem = true
            }
        }
        
        Spacer()
        ControlButton(systemIconName: "trash") {
            print("Clear Scene button pressed.")
        }
       
    }
}

struct ControlButton : View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {self.action()}) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }.frame(width: 50, height: 50)
    }
}
