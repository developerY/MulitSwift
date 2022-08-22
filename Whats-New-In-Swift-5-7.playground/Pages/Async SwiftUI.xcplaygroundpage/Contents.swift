//: [Previous](@previous)
// @MainActor - runs on the main thread
/*:
 Clean Code with MVVM and SwiftUI
 */

import Foundation
import SwiftUI
import PlaygroundSupport

var greeting = "SwiftUI"

func addEverSec(count : Int) async -> Int {
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    let num = count + 1
    return num
}

// : From Nick
// Created by Nick Sarno on 4/4/22 and adapted here:
// Thread Sanitizer - under MulitSwift(iOS) icon on the top running bar

//protocol GlobalActor
@globalActor final class MyFirstGlobalActor {
    //static var shared: Self.ActorType { get }
    static var shared = MyNewDataManager() // <- Access point
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

class GlobalActorBootcampViewModel: ObservableObject {
    // Must run on Main Actor (main thread/ UI Thread)
    @MainActor @Published var dataArray: [String] = []
    
    
    let manager = MyFirstGlobalActor.shared
    @MyFirstGlobalActor func getData() {
        
        // HEAVY COMPLEX METHODS
        Task {
            // Run on the Global Actor
            let data = await manager.getDataFromDatabase()
            print("Global Actor : \(Thread.current)")
            // Run back on the Main Actor
            await MainActor.run(body: {
                print("Main Actor : \(Thread.current)")
                self.dataArray = data // @Published on @MainActor
            })
        }
    }
    
}


struct BadCounterView: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            Text("This is the count ")
            Text("\(count)")
        }.task { // cancle when view goes away
            
            // try Task.checkCancellation()
            
            for i in 1...10 {
                print("task!!! \(i) \n")
                count = await(addEverSec(count: count))
            }
        }.onAppear {
            
            Task { // will NOT cancle when view goes away
                for i in 1...10 {
                    print("Task \(i)")
                    count = await(addEverSec(count: count))
                }
                
            }
        }
    }
    
}

struct ContentView: View {
    @State private var counterOn = false
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()


    var body: some View {
        VStack {
            // Toggle
            Toggle(isOn: $counterOn) {
                Text("Vibrate on Ring")
            }

            if (counterOn) {
                BadCounterView()
            } else {
                Text("Counter Off")
            }
            
            // List of Text
            ForEach(viewModel.dataArray, id: \.self) {
                Text($0)
                    .font(.headline)
            }
            
        }.frame(minWidth: 200, minHeight: 300)
        .onAppear {
            Task {
                await viewModel.getData()
            }
        }
    }
    
}


PlaygroundPage.current
    .setLiveView(ContentView())


//: [Next](@next)
