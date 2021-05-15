//
//  CapstoneCellscopeApp.swift
//  CapstoneCellscope
//
//  Created by Oni on 4/28/21.
//

import SwiftUI

var ble = SerialController()
import Amplify
import AmplifyPlugins

public var touch = UIImpactFeedbackGenerator(style: .heavy)
@main
struct CapstoneCellscopeApp: App {
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            Root()
        }
    }
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: models))
            
            try Amplify.configure()
            print("Amplify configured with plugins")
            
        } catch {
            print("Could not configure Amplify - \(error)")
        }
    }
}

