//
//  MulitSwiftApp.swift
//  Shared
//
//  Created by iOS Developer on 8/15/21.
//

import SwiftUI
import AsyncAlgorithms

@main
struct MulitSwiftApp: App {
    let persistenceController = PersistenceController.shared
    let exmURL = "https://www.7timer.info/bin/astro.php?lon=113.2&lat=23.1&ac=0&unit=metric&output=json&tzshift=0"
    let exmURL1 = "https://www.7timer.info/bin/astro.php?lon=13.2&lat=123.1&ac=0&unit=metric&output=json&tzshift=0"
    
    init(){
        //TestCall()
        TestCall2()
    }
    
    let a = [1,2,3]
    let b = ["a", "b", "c"]
    let c = ["😀","😡"]
    
    /*func TestCall() {
        let appleFeed = URL(string: exmURL)!.lines
        let nasdaqFeed = URL(string: exmURL1)!.lines
        Task {
            print("Stated")
            for try await (apple, nasdaq) in zip(appleFeed, nasdaqFeed) {
                
              print("APPL: \(apple) NASDAQ: \(nasdaq)")
            }
            print("End")
        }
    }*/
    
    func TestCall2() {
       
        Task {
            print("Stated")
            for try await (a, b, c) in zip(a.send(), b.send(),c.send()) {
              print("aSend: \(a) bSend: \(b) cSend \(c)")
                // if a is equal to this break
                // break
            }
            print("End")
        }
    }

    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension Array {
    func send() -> AsyncStream<Element> {
        AsyncStream {continuation in
            Task {
                for value in self {
                    continuation.yield(value)
                }
            }
        }
    }
}


// * Combines values produced into tuples
let a = [1,2,3]
let b = ["a", "b", "c"]
let c = ["😀","😡"]
