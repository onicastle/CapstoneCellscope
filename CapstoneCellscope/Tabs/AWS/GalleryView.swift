//
//  GalleryView.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/4/21.
//

import SwiftUI
import Amplify

struct GalleryView: View {
    
    @State var imageCache = [String: UIImage?]()
    
    var body: some View {
        List(imageCache.sorted(by: { $0.key > $1.key }), id: \.key) { key, image in
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            getPosts()
            observePosts()
        }
    }
    
    func getPosts() {
        Amplify.DataStore.query(Post.self) { result in
            switch result {
            case .success(let posts):
                print(posts)
                
                downloadImages(for: posts)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadImages(for posts: [Post]) {
        for post in posts {
            
            _ = Amplify.Storage.downloadData(key: post.imageKey) { result in
                switch result {
                case .success(let imageData):
                    let image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async {
                        imageCache[post.imageKey] = image
                    }
                    
                case .failure(let error):
                    print("Failed to download image data - \(error)")
                }
            }
            
        }
    }
    
    @State var token: Any?
    func observePosts() {
        token = Amplify.DataStore.publisher(for: Post.self).sink(
            receiveCompletion: { print($0) },
            receiveValue: { event in
                do {
                    let post = try event.decodeModel(as: Post.self)
                    downloadImages(for: [post])
                    
                } catch {
                    print(error)
                }
            }
        )
    }
    
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}

