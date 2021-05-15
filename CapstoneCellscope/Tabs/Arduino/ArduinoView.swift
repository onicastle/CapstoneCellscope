//
//  ArduinoView.swift
//  Cellscope
//
//  Created by Oni on 4/21/21.
//

import SwiftUI
import CoreGraphics
import CoreBluetooth


private struct ArduinoBadge: View{
    
    init() {
        let appearence = UINavigationBarAppearance()
        appearence.configureWithTransparentBackground()
    }
    
    var body: some View {
        
        NavigationView{
            
            Badge().onTapGesture {
                ble.serial.sendTest()
                print("ran text                                                ")
            }
                .navigationBarTitle(Text("Arduino Controller"))
        }
        
    }
}

struct ArduinoView: View {
    @State var connected = false
    @State var temp = Color.systemRed
    @State var message = "Connect"
    //String {
//        var message = String()
//
//        if ble.serial.connected{
//            message = "Connected"
//
//        }
//        if ble.serial.isScanning {
//            message = "Scanning"
//
//        } else {
//            message = "Start Scan?"
//
//        }
//
//
//        return message
//    }
    
    
    
    var body: some View {
        VStack{
            
        ArduinoBadge().onTapGesture {
            touch.impactOccurred()
        }
            Spacer()
            HStack(alignment: .center){
                
            }
            Button(action: {
//                message = "Scanning"
//                temp = .systemYellow
              ble.serial.startScan()
              ble.serial.startScan()
              
                if ble.serial.connected{
                    message = "Connected"
                    temp = .systemTeal
                    self.connected.toggle()
                }
                
//                   else if ble.serial.isScanning{
//                        message = "Scanning"
//                        temp = .systemYellow
//                    }
                   
                    
                    
            }, label: {
                Text("\(message)")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(alignment: .center)
                    .width(85)
                    .padding(10)
                    .foregroundColor(temp)
                    .border( temp, cornerRadius: 40)
                    .foregroundColor(temp)
                                
            })
            Divider()
            PatternControl()
        }
        
    }
}

struct ArduinoView_Previews: PreviewProvider {
    static var previews: some View {
        ArduinoView()
    }
}
