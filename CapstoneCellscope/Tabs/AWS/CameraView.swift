//
//  CameraView.swift
//  Cellscope
//
//  Created by marcos joel gonzález on 4/29/21.
//
//  adapted from tutorial by Kilo Loco https://www.youtube.com/watch?v=i9QPG-4QiwM
//

import SwiftUI
import Amplify
import Combine
//import SwiftImage


/**
 Object to save an image to iPhone's photo library.
 From https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
 */
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    @objc func saveError(_ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer) {
            print("Save finished!")
        }
}

/**
 This is the main view of the application.
 Contains the logic for uploading and downloading to and from S3.
 */
struct CameraView: View {
    
    let group = DispatchGroup()     // for asynchronous invocation of certain functions
    
    private let imageSaver = ImageSaver()       // to save image to photo library
    @State var imagesInS3Folder = [String]()    // list of image keys in S3 bucket
    
    @State var image: UIImage?
    @State var imageLeft: UIImage?
    @State var imageRight: UIImage?
    
    @State var shouldShowImagePicker = false
    @State var shouldShowLeftImagePicker = false
    @State var shouldShowRightImagePicker = false
    
    var body: some View {
        VStack {
            HStack {    // for cases when image processing method requires two images
                if let imageL = self.imageLeft {
                    Image(uiImage: imageL)
                        .resizable()
                        .scaledToFit()
                }
                if let imageR = self.imageRight {
                    Image(uiImage: imageR)
                        .resizable()
                        .scaledToFit()
                }
            }
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            Button(action: takePhotoButton, label: {
                let imageName = self.image == nil
                    ? "camera"
                    : "cloud"
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            })
            Spacer()
            
            VStack {
                Button(action: brightfieldButton, label: {
                    Text("Brightfield")
                        .frame(minWidth: 150)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(action: differentialPhaseContrastButton, label: {
                    Text("DPC")
                        .frame(minWidth: 150)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(action: thresholdingButton, label: {
                    Text("Thresholding")
                        .frame(minWidth: 150)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(action: convolutionButton, label: {
                    Text("Convolution")
                        .frame(minWidth: 150)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(action: fourierTransformButton, label: {
                    Text("Fourier Transform")
                        .frame(minWidth: 150)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
            }
            Spacer()
        }
        .sheet(isPresented: $shouldShowImagePicker, content: {
            ImagePicker(image: $image)
        })
        .sheet(isPresented: $shouldShowLeftImagePicker, content: {
            ImagePicker(image: $imageLeft)
        })
        .sheet(isPresented: $shouldShowRightImagePicker, content: {
            ImagePicker(image: $imageRight)
        })
//        .onAppear {
//            listItemsInBucketFolder()
//        }
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
    
    func takePhotoButton() {
//        listItemsInBucketFolder(folder: "unprocessed/brightfield")
//        group.notify(queue: .main) {
//            print(self.imagesInS3Folder.count)
//        }
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
    
    /**
     Save Post information to AWS DynamoDB.
     */
    func save(_ post: Post) {
        Amplify.DataStore.save(post) { result in
            switch result {
            case .success:
                print("Saved post!")
                self.image = nil
            
            case .failure(let error):
                print("Failed to save post - \(error)")
            
            }
        }
    }
    
    /**
     Download image from S3 bucket.
     
     - Parameter imageKey: folder path for image in bucket
     */
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
    
    /**
     Select a left and right picture from photo library.
     If both photos are available, locally process them and upload them to S3 for cloud processing.
     */
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
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(15)) {
//                    download(path: "processed/brightfield/bfresult+\(size+1).jpg")
//                    // download(path: "processed/brightfield/sample\(size+1)+\(size+2).jpg")
//                    // save photo to library
//                }
            }
            self.image = brightfieldProcessing(image1: imageLeft, image2: imageRight)
            
//            let group2 = DispatchGroup()
//            group2.enter()
//            var processedSize = 0
//            repeat {
//                listItemsInBucketFolder(folder: "processed/brightfield")
//                group.notify(queue: .main) {
//                    processedSize = self.imagesInS3Folder.count
//                }
//            }
//            while (processedSize <= self.imagesInS3Folder.count)
//            group2.leave()
//
//            group2.notify(queue: .main) {
//                download(path: "processed/brightfield/sample\(size+1)+\(size+2).jpg")
//                download(path: "processed/brightfield/bfresult+\(size+1).jpg")
//            }
            
//            self.image = brightfieldProcessing(image1: imageLeft, image2: imageRight) // locally process image
            
        }
        else if self.imageLeft != nil {
            shouldShowRightImagePicker.toggle()  // select the right image from photo library
        }
        else {
            shouldShowLeftImagePicker.toggle()   // select the left image from photo library
        }
    }
    
    /**
     Select a left and right picture from photo library.
     If both photos are available, locally process them and upload them to S3 for cloud processing.
     */
    func differentialPhaseContrastButton() {
        if let imageLeft = self.imageLeft, let imageRight = self.imageRight {
            self.imageLeft = nil
            self.imageRight = nil
            
//            var size = 0
//
//            listItemsInBucketFolder(folder: "unprocessed/dpc")
//            group.notify(queue: .main) {
//                size = self.imagesInS3Folder.count
//                upload(image: imageLeft, path: "unprocessed/dpc/sample\(size+1).jpg")
//                upload(image: imageRight, path: "unprocessed/dpc/sample\(size+2).jpg")
////                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(15)) {
////                    download(path: "processed/dpc/dpcresult+\(size+1).jpg")
////                    // save photo to library
////                }
//            }
            self.image = differentialPhaseContrastProcessing(image1: imageLeft, image2: imageRight)
        }
        else if self.imageLeft != nil {
            shouldShowRightImagePicker.toggle()  // select the right image from photo library
        }
        else {
            shouldShowLeftImagePicker.toggle()   // select the left image from photo library
        }
    }
    
    @State var cancellableTH: AnyCancellable?

    /**
     Select a picture from photo library.
     When the photo is available, locally process it and upload to S3 for cloud processing.
     */
    func thresholdingButton() {
        if let image = self.image {
            self.image = nil
        
            var size = 0
            
            listItemsInBucketFolder(folder: "unprocessed/thresholding")
            group.notify(queue: .main) {
                size = self.imagesInS3Folder.count
                upload(image: image, path: "unprocessed/thresholding/sample\(size+1).jpg")
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(15)) {
//                    download(path: "processed/dpc/dpcresult+\(size+1).jpg")
                    // save photo to library
//                }
            }
            self.image = thresholdingProcessing(image: image)
        }
        else {
            shouldShowImagePicker.toggle()
        }
    }

    func convolutionButton() {
        if let image = self.image {
            self.image = nil
        
            var size = 0
            
            listItemsInBucketFolder(folder: "unprocessed/convolution")
            group.notify(queue: .main) {
                size = self.imagesInS3Folder.count
                upload(image: image, path: "unprocessed/convolution/sample\(size+1).jpg")
            }
        }
        else {
            shouldShowImagePicker.toggle()
        }
    }

    func fourierTransformButton() {
        if let image = self.image {
            self.image = nil
        
            var size = 0
            
            listItemsInBucketFolder(folder: "unprocessed/fourier")
            group.notify(queue: .main) {
                size = self.imagesInS3Folder.count
                upload(image: image, path: "unprocessed/fourier/sample\(size+1).jpg")
            }
        }
        else {
            shouldShowImagePicker.toggle()
        }
    }
    
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
