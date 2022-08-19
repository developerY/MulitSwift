//: [Previous](@previous)

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

struct CounterView: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            Text("This is the count ")
            Text("\(count)")
        }.task { // cancle when view goes away
            for i in 1...100 {
                print("task!!! \(i) \n")
                count = await(addEverSec(count: count))
            }
        }.onAppear {
            Task { // will NOT cancle when view goes away
                for i in 1...100 {
                    print("Task \(i)")
                    count = await(addEverSec(count: count))
                }
            }
        }
    }
    
}

struct ContentView: View {
    @State private var vibrateOnRing = false

    var body: some View {
        Toggle(isOn: $vibrateOnRing) {
            Text("Vibrate on Ring")
        }
        
        if (vibrateOnRing) {
            Text("Counter Off")
        } else {
            CounterView()
        }
    }
    
}


PlaygroundPage.current
    .setLiveView(ContentView())


//: [Next](@next)
