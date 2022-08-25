//
//  ImageView.swift
//  MulitSwift
//
//  Created by Siamak Ashrafi on 8/21/22.
//

import SwiftUI

struct ImageViewUI: View {
    @ObservedObject var imageService = ImageService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Count \(imageService.count) Timer!")
            
            AsyncImage(url: imageService.url) { image in
                image.resizable()
                    //.aspectRatio(contentMode:.fit)
            } placeholder: {
                ProgressView()
            }.task {
               await imageService.starTimer()
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewUI()
    }
}
