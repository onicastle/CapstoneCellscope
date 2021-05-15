//
//  CameraTabView.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/11/21.
//

import SwiftUI

struct CameraTabView: View {
    
    init() {
        let appearence = UINavigationBarAppearance()
        appearence.configureWithTransparentBackground()
    }
    
    @State var brightfield = false
    @State var darkfield = false
    var darkfieldLabel: some View = Label("Darkfield", systemImage: "photo")
        .labelStyle(ScriptLabel())
    
    var brightfieldLabel: some View = Label("Brightfield", systemImage: "photo.fill")
        .labelStyle(ScriptLabel())

    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    NavigationLink(
                        destination: BrightfieldCameraView()
                            .navigationBarTitle("")
                            .navigationBarHidden(false),
                        isActive: $brightfield
                    ) {
                        brightfieldLabel
                    }
                    
                    NavigationLink(
                                        destination: DarkfieldCameraView()
                                            .navigationBarTitle("")
                                            .navigationBarHidden(true),
                                        isActive: $darkfield
                                    ) {
                                            darkfieldLabel
                                    }
                    brightfieldLabel
                }
            }
        }
    }
}

struct CameraTabView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTabView()
    }
}

//extension CameraTabView{
//
//
//}
