//
//  LabelStyle.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/9/21.
//

import Foundation
import SwiftUI

struct ScriptLabel: LabelStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack{
            configuration.icon
                .font(.title, weight: .bold)
                .foregroundColor(.systemBlue)
                
            
            configuration.title
                .font(.title, weight: .bold)
                .foregroundColor(.systemBlue)
                
        }
    }
}
