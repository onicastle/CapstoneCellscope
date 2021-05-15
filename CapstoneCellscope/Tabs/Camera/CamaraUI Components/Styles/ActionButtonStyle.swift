//
//  ActionButton.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/2/21.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.systemRed)
            .padding()
            .overlay(
                Capsule().stroke(Color.systemRed, lineWidth: 6).padding(0)
            )
    }
    
    
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Scan", action: {
            print("Booooo")
        }).buttonStyle(ActionButtonStyle())
    }
}
