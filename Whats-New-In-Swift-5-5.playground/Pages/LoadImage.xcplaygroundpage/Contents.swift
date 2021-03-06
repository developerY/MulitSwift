//: [Previous](@previous)
/*:
```
 AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
     image.resizable()
 } placeholder: {
     ProgressView()
 }
 .frame(width: 50, height: 50)
```
 */

import Foundation
import SwiftUI
import PlaygroundSupport

// Swift 5.5 Async / Await
var greeting = "Hello, playground"
let paul = URL(string: "https://www.hackingwithswift.com/img/paul@2x.png")

// Random Pic

var randomPic = URL(string: "https://source.unsplash.com/random/300x200")
let pic = URL(string: "https://images.unsplash.com/photo-1526849875464-471c91f5ecae?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=510&q=200")


// From Swift 5.5
func inCount() async {
    await Task.sleep(2_000_000_000) // called every two sec.
    randomPic = URL(string: "https://source.unsplash.com/random/300x200?sig=\(Int.random(in: 1..<100))")
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("hi")
            AsyncImage(url: randomPic) { image in
                image.resizable()
                    .aspectRatio(contentMode:.fit)
            } placeholder: {
                ProgressView()
            }/*.task {
                await inCount()
            }*/
        }
        .frame(minWidth: 300,
                minHeight: 400,
                alignment: .topLeading)
    }
}

PlaygroundPage.current
    .setLiveView(ContentView())

//: [Next](@next)
