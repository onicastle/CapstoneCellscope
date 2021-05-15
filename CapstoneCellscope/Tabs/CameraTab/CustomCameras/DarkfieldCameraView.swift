//
//  DarkfieldCameraView.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/11/21.
//

import SwiftUI

struct DarkfieldCameraView: View {
    @StateObject var model = CameraModel()
    @State var showSheet = false
    @State var currentZoomFactor: CGFloat = 1.0
    
    @State var temp = Color.systemRed
    
    var captureButton: some View {
        Button(action: {
            touch.impactOccurred()
            model.capturePhoto()
        }, label: {
            
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    
    var capturedPhotoThumbnail: some View {
        Group {
            if model.photo != nil {
                Image(uiImage: model.photo.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .animation(.spring())

            } else {
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
        .onTapGesture {
            showSheet.toggle()
            
        }.sheet(isPresented: $showSheet, content: {
//            library
        })


           
    }
//    //MARK: Added ImageSelector
//    @State var image: Data?
//    var library: some View {
//        VStack {
//            ImagePicker(data: $image, encoding: .png, onCancel: {
//                showSheet.toggle()
//
//            })
//
//            if let image = image {
//                Image(data: image)?
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 200,height: 200)
//                    .clipped()
//            }
//        }
//    }
    
    
    @State var message: String = "Scan"
    //MARK: Change Camera
     var actionButton: some View {
        return HStack{
            
                Button(action: {
                    touch.impactOccurred()
                    ble.serial.startScan()
                    ble.serial.startScan()
                    print(ble.serial.connected)
                    DispatchQueue.main.async {
                        while ble.serial.connected == false{
                            continue
                        }
                            message = "Connected"
                                        
                            self.temp = Color.systemTeal
                        
                    }
                }, label: {
                    Text("\(message)")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(alignment: .center)
                        .width(85)
                        .padding(10)
                        .foregroundColor(temp)
                        .border(temp , cornerRadius: 40)
                        .foregroundColor(temp)
                })
                

//            .border(ble.serial.connected == false ? Color.systemRed : Color.systemTeal, width: 6)
            
        }
//        Text("Scan").foregroundColor(.systemRed)
//            .frame(width: 40, height: 15, alignment: .center)
//            .padding()
//            .overlay(
//                Capsule()
//                    .stroke(
//                        ble.serial.connected == false ? Color.systemRed : Color.systemTeal, lineWidth: 6)
//                .padding(0)
//            ).onTapGesture {
//                ble.serial.startScan()
//                ble.serial.startScan()
//            }
//        Button(action: {
//            model.flipCamera()
//            ble.serial.startScan()
//        }, label: {
//            Image(systemName: "command.circle.fill")
//                .frame(width: 25, height: 25, alignment: .center)
//                .padding()
//                .overlay(
//                    Circle()
//                        .stroke(Color.systemTeal, lineWidth: 4)
//                    .padding(6)
//                )
//        })
//            Circle()
//                .foregroundColor(Color.gray.opacity(0.2))
//                .frame(width: 45, height: 45, alignment: .center)
//                .overlay(
//                    Image(systemName: "command.circle.fill")
//                        .foregroundColor(.white))
//        })
    }
    
    var uploadPatternButton: some View{
        
            Button(action: {
                touch.impactOccurred()
                model.flipCamera()
            }, label: {
                Circle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: 45, height: 45, alignment: .center)
                    .overlay(
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white))
            }) .frame(width: 200,height: 200)
        
    }
    var flipCameraButton: some View {
        Button(action: {
            touch.impactOccurred()
            model.flipCamera()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    actionButton
//                    Button(action: {
//                        model.switchFlash()
//                    }, label: {
//                        Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
//                            .font(.system(size: 20, weight: .medium, design: .default))
//                    })
//                    .accentColor(model.isFlashOn ? .yellow : .white)
                   
                    
                    CameraViewRepresentable(session: model.session)
                        .gesture(
                            DragGesture().onChanged({ (val) in
                                //  Only accept vertical drag
                                if abs(val.translation.height) > abs(val.translation.width) {
                                    //  Get the percentage of vertical screen space covered by drag
                                    let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                    //  Calculate new zoom factor
                                    let calc = currentZoomFactor + percentage
                                    //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                    let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                    //  Store the newly calculated zoom factor
                                    currentZoomFactor = zoomFactor
                                    //  Sets the zoom factor to the capture device session
                                    model.zoom(with: zoomFactor)
                                }
                            })
                        )
                        .onAppear {
                            model.configure()
                        }
                        .alert(isPresented: $model.showAlertError, content: {
                            Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                touch.impactOccurred()
                                model.alertError.primaryAction?()
                            }))
                        })
                        .overlay(
                            Group {
                                if model.willCapturePhoto {
                                    Color.black
                                }
                            }
                        )
//                        .animation(.easeInOut)
                    
                    
                    
                    
                    HStack{
                        //MARK: Pattern Controller View
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
                    HStack{
                        capturedPhotoThumbnail
                        
                        
                        Spacer()
                        
                        captureButton
                        
                        Spacer()
                        
                        flipCameraButton
                        
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

}

struct DarkfieldCameraView_Previews: PreviewProvider {
    static var previews: some View {
        DarkfieldCameraView()
    }
}