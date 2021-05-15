//
//  Badge.swift
//  Cellscope
//
//  Created by Oni on 4/21/21.
//

import SwiftUI

//struct Badge: View {
//
//    static let rotationCount = 8
//
//    var badgeSymbols: some View {
//        ForEach(0..<Badge.rotationCount) { index in
//            RotatedBadgeSymbol(
//                angle: .degrees(Double(index) / Double(Badge.rotationCount)) * 360.0
//            )
//        }
//        .opacity(0.5)
//    }
//
//    var body: some View {
//        ZStack {
//            ZStack{
//                BadgeBackground()
//                VStack{
//                    VStack{
//                    VStack{
//                    Image("Arduino")
//                    .renderingMode(.original)
//                        .resizable()
//                        .padding()
//                        .frame(width: 200, height: 155)
//                        .cornerRadius(25)
//                    }
//                        VStack(alignment: .leading){
//                        Text("Arduino")
//                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                            .foregroundColor(.black)
//
//                        }
//                    }
//
//                }
//
//            }.scaledToFit()
//        }.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
//
//    }
//}
var badgeIcon: some View{
    VStack{
    Image(systemName: "scope")
    .renderingMode(.original)
        .resizable()
        .padding(100)
//                        .frame(width: 200, height: 155)
//                        .cornerRadius(25)
    }
}
import UIKit
import CoreGraphics

struct Badge: View {

    

    static let rotationCount = 8

    var badgeSymbols: some View {
        ForEach(0..<Badge.rotationCount) { index in
            RotatedBadgeSymbol(
                angle: .degrees(Double(index) / Double(Badge.rotationCount)) * 360.0
            )
        }
        .opacity(0.5)
    }

    var body: some View {
        ZStack {
            ZStack{
                BadgeBackground()
                VStack{
                    VStack{
                   badgeIcon
//                        VStack(alignment: .leading){
//                        Text("Arduino")
//                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                            .foregroundColor(.black)
//
//                        }
                    }
                    
                }
            
            }.scaledToFit()
        }.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)

    }
}


struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Badge()
    
        }
    }
}


