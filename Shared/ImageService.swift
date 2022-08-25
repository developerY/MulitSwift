//
//  File.swift
//  File
//
//  Created by iOS Developer on 8/15/21.
//

import Foundation
import Combine

@MainActor
class ImageService: ObservableObject {
    // This is already reactive.
    @Published private(set) var url = URL(string: "https://source.unsplash.com/random/300x200")
    @Published private(set) var count = 0
    
    // From Swift 5.5
    func inCount() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000) // called every two sec.
        count += 1
        url = URL(string: "https://source.unsplash.com/random/300x200?sig=\(Int.random(in: 1..<100))")
    }
    
    //@MainActor
    func starTimer() async {
        for _ in 0...100 {
            await inCount()
        }
    }
}
