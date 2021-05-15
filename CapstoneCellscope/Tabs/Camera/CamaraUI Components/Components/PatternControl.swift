//
//  PatternControl.swift
//  CapstoneCellscope
//
//  Created by Oni on 4/29/21.
//

import SwiftUI


struct PatternControl: View {
    
    var body: some View {
        
        HStack(alignment: .center){
            HStack{
                
                Button("DF", action: {
                    touch.impactOccurred()
                        ble.serial.sendMessageToDevice("1")
                    

                }).buttonStyle(PatternButtonStyle())
                
                Button("BFR", action: {
                        touch.impactOccurred()
                        ble.serial.sendMessageToDevice("2")
                    
                }).buttonStyle(PatternButtonStyle())
                
                Button("BRL", action: {
                        touch.impactOccurred()
                        ble.serial.sendMessageToDevice("3")
                    
                }).buttonStyle(PatternButtonStyle())
                
                Button("PCU", action: {
                        touch.impactOccurred()
                        ble.serial.sendMessageToDevice("4")
                    
                }).buttonStyle(PatternButtonStyle())
                
                Button("PCD", action: {
                    touch.impactOccurred()
                        ble.serial.sendMessageToDevice("5")
                    
                }).buttonStyle(PatternButtonStyle())
                
                Button("Off", action: {
                    touch.impactOccurred()
                        ble.serial.sendMessageToDevice("6")
                }).buttonStyle(PatternButtonStyle())
            }
        }
        
    }
}

var darkFieldPattern: some View{
    HStack(alignment: .center){
        HStack{
            Button("DF", action: {
                touch.impactOccurred()
                    ble.serial.sendMessageToDevice("1")
            }).buttonStyle(PatternButtonStyle())
            
            Button("Off", action: {
                touch.impactOccurred()
                    ble.serial.sendMessageToDevice("6")
                
            }).buttonStyle(PatternButtonStyle())
        }
    }
}
var brighfieldPattern: some View {
    HStack(alignment: .center){
        HStack{
            Button("BFR", action: {
                    touch.impactOccurred()
                    ble.serial.sendMessageToDevice("2")
                
            }).buttonStyle(PatternButtonStyle())
            
            Button("BRL", action: {
                    touch.impactOccurred()
                    ble.serial.sendMessageToDevice("3")
            }).buttonStyle(PatternButtonStyle())
            
            Button("Off", action: {
                touch.impactOccurred()
                    ble.serial.sendMessageToDevice("6")
        }).buttonStyle(PatternButtonStyle())
        }
    }
}

var phaseContrastPattern: some View {
    HStack(alignment: .center){
        HStack{
            Button("PCU", action: {
                    touch.impactOccurred()
                    ble.serial.sendMessageToDevice("4")
                
            }).buttonStyle(PatternButtonStyle())
            
            Button("PCD", action: {
                touch.impactOccurred()
                    ble.serial.sendMessageToDevice("5")
                
            }).buttonStyle(PatternButtonStyle())
            
            Button("Off", action: {
                touch.impactOccurred()
                    ble.serial.sendMessageToDevice("6")
            }).buttonStyle(PatternButtonStyle())
        }
    }
}

struct PatternControl_Previews: PreviewProvider {
    static var previews: some View {
        PatternControl()
    }
}

