//
//  PatternButtonStyle.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/2/21.
//

import SwiftUI

struct PatternButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 26, height: 26, alignment: .center)
            .font(.caption)
            .padding()
            .overlay(
                Circle().stroke(Color.systemTeal, lineWidth: 4).padding(6)
            )
    }
}


struct PatternButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("1", action: {
            print(1)
        }).buttonStyle(PatternButtonStyle())
    }
}
