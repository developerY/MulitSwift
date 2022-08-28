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


// MARK: From Nick
// MARK: Closure
let url = URL(string: "https://picsum.photos/200")!

//Passed to the completion handler
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
// Using Combine URLSession -- Very Clean but does not throw
func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(handleResponse)
        .mapError({ $0 })
        .eraseToAnyPublisher()
}


// MARK: Async
// Using async await URLSession -- Very Clean
func downloadWithAsync() async throws -> UIImage? {
    do {
        // iOS 7.0+ but the added async version (like many of there oler APIs)
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return handleResponse(data: data, response: response)
    } catch {
        throw error
    }
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

struct SwiftUIAsyncImage : View {
    @State var msg = "blank"
    @State var imgURL = "https://picsum.photos/100"
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(msg)
            // iOS 15.0+
            
            AsyncImage(url: URL(string:"https://picsum.photos/100")) { phase in
                if let image = phase.image {
                    image // Displays the loaded image.
                } else if phase.error != nil {
                    Color.red // Indicates an error.
                } else {
                    Color.blue // Acts as a placeholder.
                }
            }
            
            
            // Amazing rotating image viewer in a few lines of code
            AsyncImage(url: URL(string:imgURL)) { image in
                image.resizable()
                    .aspectRatio(contentMode:.fit)
            } placeholder: {
                ProgressView()
            }.task {
                while(true) {
                    try? await Task.sleep(nanoseconds: 4_000_000_000)
                    let rand = Int.random(in: 100...150)
                    imgURL = "https://picsum.photos/\(rand)"
                    print("This is the URL \(imgURL)")
                }
            }
        }
        .frame(minWidth: 100,
               minHeight: 200)
    }
}




struct ContentView: View {
    var body: some View {
        
        VStack() {
            AsycnImgView()
            SwiftUIAsyncImage()
        }.frame(minWidth: 100,
                minHeight: 500)
    }
}


PlaygroundPage.current
    .setLiveView(ContentView())

//: [Next](@next)
