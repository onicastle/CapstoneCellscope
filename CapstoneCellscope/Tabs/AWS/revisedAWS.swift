//
//  revisedAWS.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/5/21.
//

import SwiftUI
import Amplify
import SwiftImage

struct revisedAWS: View {
    @State var imageCounter = 4
    private let group = DispatchGroup()

    @State var shouldShowImagePicker = false
    @State var image: UIImage?

    @State var shouldShowBrightfieldImage = false
    @State var brightfieldImage: UIImage?

    @State var shouldShowDifferentialPhaseContrastImage = false
    @State var differentialPhaseContrastImage: UIImage?

    var body: some View {

//        Menu("Action") {
//
//            Button(action: {
//                brightefieldButton()
//            }, label: {
//                Label("Brightfield", image: "Arduino")
//            })
//
//            Button(action: {
//                differentialPhaseContrastButton()
//            }, label: {
//                Label("DPC", image: "Arduino")
//            })
//
//        }


        VStack {
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            Spacer()

            Button(action: takePhotoButton, label: {
                let imageName = self.image == nil
                    ? "camera"
                    : "icloud.and.arrow.up"
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            })
            Spacer()
            HStack {
                Button(action: brightfieldButton, label: {
                    Text("Brightfield")
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                Button(action: differentialPhaseContrastButton, label: {
                       Text("DPC")
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(minWidth: 10.0)
            }
            HStack {
                Button(action: {}, label: {
                    Text("Quantitative Phase Imaging")
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                Button(action: {}, label: {
                       Text("Custom")
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
        .sheet(isPresented: $shouldShowBrightfieldImage, content: {
            Image(uiImage: brightfieldImage!)
        })
    }

    func takePhotoButton() {
        if let image = self.image {
            upload(image: image, subfolder: "unprocessed")
        }
        else {
            shouldShowImagePicker.toggle()
        }
    }

    // upload an image to AWS S3 bucket
    func upload(image: UIImage, subfolder: String){
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {return}
        let key = subfolder + "/sample" + String(imageCounter) + ".jpg"

        _ = Amplify.Storage.uploadData(key: key, data: imageData) { result in
            switch result {
            case .success:
                print("Uploaded image!")
                imageCounter += 1

                let post = Post(imageKey: key)
                save(post)

            case .failure(let error):
                print("Failed to upload - \(error)")

            }
        }
    }

    // save post information to AWS DataStore
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

    @State var imageData1 = Data()
    @State var imageData2 = Data()
    @State var cancellableBF1: Any?
    @State var cancellableBF2: Any?

    func brightfieldButton() {
        brightfieldDownload()
        shouldShowBrightfieldImage.toggle()
    }

    // download two images from unprocessed/samples/ and run bf processing algorithm
    func brightfieldDownload() {
        imageCounter -= 1
        let storageOperation1 = Amplify.Storage.downloadData(key: "unprocessed/sample\(imageCounter).jpg")
        cancellableBF1 = storageOperation1.resultPublisher.sink (
            receiveCompletion: {completion in
                if case .failure(let error) = completion{
                    print(error)
                }
            },
            receiveValue: {data in
                self.imageData1 = data
                print("Image data 1 - \(data)")
            })

        imageCounter -= 1
        let storageOperation2 = Amplify.Storage.downloadData(key: "unprocessed/sample\(imageCounter).jpg")
        cancellableBF2 = storageOperation2.resultPublisher.sink (
            receiveCompletion: {completion in
                if case .failure(let error) = completion{
                    print(error)
                }
            },
            receiveValue: {data in
                self.imageData2 = data
                group.enter()
                brightfieldProcessing(leftData: self.imageData1, rightData: self.imageData2)
                group.leave()
                print("Image data 2 - \(data)")
            })

        shouldShowBrightfieldImage.toggle()
    }

    func brightfieldProcessing(leftData: Data, rightData: Data) {
        guard let leftImage = SwiftImage.Image<RGBA<UInt8>>(data: leftData)?.resizedTo(width: 20, height: 20)
            else {return}
        guard let rightImage = SwiftImage.Image<RGBA<UInt8>>(data: rightData)?.resizedTo(width: 20, height: 20)
            else {return}

        var pixels: [RGBA<UInt8>] = []
        for x in 0...leftImage.height-1 {
            for y in 0...leftImage.width-1 {
                if y < leftImage.width/2 {
                    pixels.append(leftImage[x,y])
                }
                else {
                    pixels.append(rightImage[x,y])
                }
            }
        }

        let imageSaver = ImageSaver()
        self.brightfieldImage = SwiftImage.Image<RGBA<UInt8>>(width: 20, height: 20, pixels: pixels).uiImage
        imageSaver.writeToPhotoAlbum(image: self.brightfieldImage!)
        DispatchQueue.main.async {
            upload(image: self.brightfieldImage!, subfolder: "brightfield")
        }

        print("-----Brightfield processing DONE-----")
    }

    @State var cancellableDPC1: Any?
    @State var cancellableDPC2: Any?

    func differentialPhaseContrastButton() {
        differentialPhaseContrastDownload()
        shouldShowDifferentialPhaseContrastImage.toggle()
    }

    func differentialPhaseContrastDownload() {
        imageCounter -= 1
        let storageOperation1 = Amplify.Storage.downloadData(key: "unprocessed/sample\(imageCounter).jpg")
        cancellableDPC1 = storageOperation1.resultPublisher.sink (
            receiveCompletion: {completion in
                if case .failure(let error) = completion{
                    print(error)
                }
            },
            receiveValue: {data in
                self.imageData1 = data
                print("Image data 1 - \(data)")
            })

        imageCounter -= 1
        let storageOperation2 = Amplify.Storage.downloadData(key: "unprocessed/sample\(imageCounter).jpg")
        cancellableDPC2 = storageOperation2.resultPublisher.sink (
            receiveCompletion: {completion in
                if case .failure(let error) = completion{
                    print(error)
                }
            },
            receiveValue: {data in
                self.imageData2 = data
                DispatchQueue.main.async {
                    differentialPhaseContrastProcessing(data1: self.imageData1, data2: self.imageData2)
                }
                print("Image data 2 - \(data)")
            })

        shouldShowDifferentialPhaseContrastImage.toggle()

    }

    func differentialPhaseContrastProcessing(data1: Data, data2: Data) {
        guard let image1 = SwiftImage.Image<RGBA<UInt8>>(data: data1)?.resizedTo(width: 20, height: 20)
            else {return}
        guard let image2 = SwiftImage.Image<RGBA<UInt8>>(data: data2)?.resizedTo(width: 20, height: 20)
            else {return}

        var pixels: [RGBA<UInt8>] = []
        for x in 0...image1.height-1 {
            for y in 0...image1.width-1 {
                let pixelsSum = [image1[x,y].red.addingReportingOverflow(image2[x,y].red).partialValue,
                                 image1[x,y].green.addingReportingOverflow(image2[x,y].green).partialValue,
                                 image1[x,y].blue.addingReportingOverflow(image2[x,y].blue).partialValue,
                                 image1[x,y].alpha.addingReportingOverflow(image2[x,y].alpha).partialValue]
                let tempPixel = RGBA(red: pixelsSum[0],
                                     green: pixelsSum[1],
                                     blue: pixelsSum[2],
                                     alpha: pixelsSum[3])
                pixels.append(tempPixel)
            }
        }

        let imageSaver = ImageSaver()
        self.image = SwiftImage.Image<RGBA<UInt8>>(width: 20, height: 20, pixels: pixels).uiImage
        imageSaver.writeToPhotoAlbum(image: self.image!)
        DispatchQueue.main.async {
            upload(image: self.image!, subfolder: "dpc")
        }

        print("-----Differential Phase Contrast processing DONE-----")
    }
}

struct revisedAWS_Previews: PreviewProvider {
    static var previews: some View {
        revisedAWS()
    }
}
