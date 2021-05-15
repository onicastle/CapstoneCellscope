 //
//  CustomTabBar.swift
//  Cellscope
//
//  Created by Oni on 4/23/21.
//

import SwiftUI
 

struct Root: View {
    @State var selectedIndex = 0
    @State var shouldShowModel = false
    //["command.circle.fill", "building.2.crop.circle.fill", "plus.circle.fill", "wave.3.forward.circle.fill", "icloud.circle.fill"]
    let tabBarImageNames = ["command", "plus.circle.fill","light.max"]
    var body: some View {
        VStack{
            ZStack{
                //Opens Camera View
                Spacer().fullScreenCover(isPresented: .constant(shouldShowModel), content: {
                    Button(action: {
                        shouldShowModel.toggle();
                    }, label: {
                        CCameraView()
                    })
                })
                
                switch selectedIndex{
                case 0:
                    AWSCameraView()
//                    SwiftUIImagePicker()
//                ImageHandler()
//                    ScriptsView()
//                    NavigationView{
//                    ArduinoView()
//                    }
                case 1:
                    CCameraView()
//                    ResourcesTab()
                case 2:
                    ArduinoView()
                case 3:
                    AWSCameraView()
                case 4:
//                    BluetoothView()
                    GalleryView()
                default:
                    EmptyView()
                }
            }
//            Text("VStack")
            
            Spacer()
            
            HStack{
                ForEach(0..<3){
                    num in
                    Button(action: {
                        if num == 1{
//                            //For some reason this sequence of functions allows the bluetooth to work.. idk.
//                            ble.serial.startScan()
//                            ble.serial.startScan()
//
////                            shouldShowModel.toggle()
//                            return
                        }
                    }, label: {
                        Spacer()
                        
                        if num == 1{
                            
                            Image(systemName: tabBarImageNames[num]).onTapGesture {
                                touch.impactOccurred(intensity: 1)
                                self.selectedIndex = 1
                            }

                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.red)
                        }
                        else{
                            Image(systemName: tabBarImageNames[num]).font(.system(size: 24, weight: .bold)).foregroundColor(selectedIndex == num ? Color(.systemTeal) : Color.init(white: 0.9)).onTapGesture {
                                touch.impactOccurred()
                                self.selectedIndex = num
                            }
                        }
                        Spacer()
                    })
                }
            }
        }
    
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        Root()
    }
}

