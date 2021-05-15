//
//  CaptureButtonStyle.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/2/21.
//

import SwiftUI

struct CaptureButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.background(Circle()
            .foregroundColor(.white)
            .frame(width: 80, height: 80, alignment: .center)
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 2)
                    .frame(width: 65, height: 65, alignment: .center)
            )
        )
    }
}

struct CaptureButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("", action: {
            print("hi")
        }).preferredColorScheme(.dark)
        .buttonStyle(CaptureButtonStyle())
        
    }
}
