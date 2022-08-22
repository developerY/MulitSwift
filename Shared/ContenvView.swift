//
//  TimeList.swift
//  TimeList
//
//  Created by iOS Developer on 8/15/21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ImageViewUI()
                .tabItem {
                    Label("Photo", systemImage: "photo")
                }
            DemoListViewUI()
                .tabItem{
                    Label("List", systemImage: "list.clipboard")
                }
        }
        
    }
    
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
