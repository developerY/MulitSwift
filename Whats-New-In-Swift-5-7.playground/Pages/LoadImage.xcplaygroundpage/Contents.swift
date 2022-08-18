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
import Combine
import PlaygroundSupport

// Swift 5.5 Async / Await
var greeting = "Hello, playground"
let paul = URL(string: "https://www.hackingwithswift.com/img/paul@2x.png")

// Random Pic

var randomPic = URL(string: "https://source.unsplash.com/random/300x200")
let pic = URL(string: "https://images.unsplash.com/photo-1526849875464-471c91f5ecae?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=510&q=200")


// MARK: From Nick
// MARK: Closure
let url = URL(string: "https://picsum.photos/200")!

func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
    guard
        let data = data,
        let image = UIImage(data: data),
        let response = response as? HTTPURLResponse,
        response.statusCode >= 200 && response.statusCode < 300 else {
        return nil
    }
    return image
}

/*
 1. anytime you type @escaping --- be cautious --- This is for the programmer not the compiler
 2. anytime you type [weak self] --- be cautious --- This is tricky
 */
func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { /*[weak self]*/ data, response, error in
        let image = handleResponse(data: data, response: response)
        completionHandler(image, error)
    }
    .resume()
}

// MARK: Combine
func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(handleResponse)
        .mapError({ $0 })
        .eraseToAnyPublisher()
}


// MARK: Async
func downloadWithAsync() async throws -> UIImage? {
    do {
        // iOS 7.0+ but the added async version (like many of there oler APIs)
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return handleResponse(data: data, response: response)
    } catch {
        throw error
    }
}


// From Swift 5.5
func inCount() async {
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    randomPic = URL(string: "https://source.unsplash.com/random/300x200?sig=\(Int.random(in: 1..<100))")
    
}

struct AsycnImgView: View {
    @State var msg = "blank"
    @State var img: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(msg)
            if let goodImg = img {
                Image(uiImage:goodImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 200)
            }
        }.onAppear() {
            Task {
                do {
                    if let downLoadImg = try await downloadWithAsync() {
                        img = downLoadImg
                        msg = "Done loading image"
                    }
                }catch {
                    msg = error.localizedDescription
                }
            }
            msg = "Loading image"
        }
        
    }
}

struct ContentView: View {
    var body: some View {
        
        VStack() {
            VStack(alignment: .leading, spacing: 20) {
                // iOS 15.0+
                AsyncImage(url: randomPic) { image in
                    image.resizable()
                        .aspectRatio(contentMode:.fit)
                } placeholder: {
                    ProgressView()
                }/*.task {
                  await inCount()
                  }*/
            }
            .frame(minWidth: 100,
                   minHeight: 200)
            AsycnImgView()
        }.frame(minWidth: 100,
                minHeight: 500)
    }
}


PlaygroundPage.current
    .setLiveView(ContentView())

//: [Next](@next)
