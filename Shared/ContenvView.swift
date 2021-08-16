//
//  TimeList.swift
//  TimeList
//
//  Created by iOS Developer on 8/15/21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var imageService = ImageService()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Count \(imageService.count) Timer!")
                /*.onReceive(imageService.timer) { newCurrentTime in
                    self.currentTime = newCurrentTime
                }*/
            AsyncImage(url: imageService.url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
    
        }
    }
    
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
