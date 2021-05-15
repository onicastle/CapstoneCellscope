//
//  BrightfieldCameraView.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/11/21.
//
import SwiftUI
import Amplify
import Combine
import SwiftImage

struct BrightfieldCameraView: View {
    @StateObject var model = CameraModel()
    @State var showSheet = false
    @State var currentZoomFactor: CGFloat = 1.0
    @State var imageLeft: UIImage?
    private let imageSaver = ImageSaver() 
    @State var imageRight: UIImage?
    @State var imagesInS3Folder = [String]()    // list of image keys in S3 bucket
    let group = DispatchGroup()     // for asynchronous invocation of certain functions
    @State var image: UIImage?
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
    
    
    func brightfieldButton() {
        if let imageLeft = self.imageLeft, let imageRight = self.imageRight {
            self.imageLeft = nil
            self.imageRight = nil
            
            var size = 0
            
            listItemsInBucketFolder(folder: "unprocessed/brightfield")
            group.notify(queue: .main) {
                size = self.imagesInS3Folder.count
                upload(image: imageLeft, path: "unprocessed/brightfield/sample\(size+1).jpg")
                upload(image: imageRight, path: "unprocessed/brightfield/sample\(size+2).jpg")
            }
            
            // wait 20 seconds for upload and cloud processing
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) {
                download(path: "processed/brightfield/sample\(size+1)+\(size+2).jpg")
            }
            
            self.image = brightfieldProcessing(image1: imageLeft, image2: imageRight)
        }
        else if self.imageLeft != nil {
              // select the right image from photo library
        }
        else {
             // select the left image from photo library
        }
    }
    
    @State var listenToken: AnyCancellable?
    func listItemsInBucketFolder(folder: String) {
        group.enter()   // necessary because multithreading
        
        listenToken = Amplify.Storage.list().resultPublisher.sink(
            receiveCompletion: { completion in
                if case let .failure(storageError) = completion {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            },
            receiveValue: { listResult in
                DispatchQueue.main.async {
                    self.imagesInS3Folder.removeAll()   // erase the old contents
                    
                    listResult.items.forEach { item in
                    
                        if item.key.hasPrefix(folder) &&
                            (item.key.hasSuffix(".jpg") || item.key.hasSuffix(".png")) {
                           
                            self.imagesInS3Folder.append(item.key)
                                
                        }
                    }
                    group.leave()
                }
            })
    }
    
    @State var downloadToken: AnyCancellable?
    func download(path: String) {
        downloadToken = Amplify.Storage.downloadData(key: path).resultPublisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            },
            receiveValue: { data in
                let image = UIImage(data: data)
                print("Downloaded image: \(path)")
                DispatchQueue.main.async {
                    self.imageSaver.writeToPhotoAlbum(image: image!)
                }
            })
    }
    
    // Upload an image to AWS S3 bucket.
    func upload(image: UIImage, path: String){
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        
        _ = Amplify.Storage.uploadData(key: path, data: imageData) { result in
            switch result {
            case .success:
                print("Uploaded image!")
            
            case .failure(let error):
                print("Failed to upload - \(error)")
            
            }
        }
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

struct BrightfieldCameraView_Previews: PreviewProvider {
    static var previews: some View {
        BrightfieldCameraView()
    }
}
