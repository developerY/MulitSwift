//
//  ViewModel.swift
//  MulitSwift
//
//  Created by Siamak Ashrafi on 8/21/22.
//

import Foundation
import AsyncAlgorithms


// Just put @MainActor Here
//@MainActor // This solves everything.
class ViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    let exmURL = "https://www.7timer.info/bin/astro.php?lon=113.2&lat=23.1&ac=0&unit=metric&output=json&tzshift=0"
    let exmURL1 = "https://www.7timer.info/bin/astro.php?lon=13.2&lat=123.1&ac=0&unit=metric&output=json&tzshift=0"
    
    let a = [1,2,3]
    let b = ["a", "b", "c"]
    let c = ["😀","😡"]
    let d = [5,7,9,10]
    
    @MainActor @Published var zipList : [String] = [] // Comment out @MainActor
    @MainActor @Published var mergeList : [Int] = []
    
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
    
    func taskZip() {
        print("Stated Zip")
        Task {
            for try await (a, b, c) in zip(a.send(), b.send(),c.send()) {
                await MainActor.run(body: {
                    zipList.append("aSend: \(a) bSend: \(b) cSend \(c)")
                })
                // if a is equal to this break
                // break
            }
            
        }
        print("End Zip")
    }
    
    func deleteZip() {
        Task {
            await MainActor.run(body: {
                zipList.removeAll()
            })
        }
    }
    
    func taskMerge() {
        print("Stated Merge")
        Task {
            
            for try await myNums in merge(a.send(), d.send()) {
                await MainActor.run(body: {
                    mergeList.append(myNums)
                })
            }
            
        }
        print("End Merge")
    }
    
    func deleteMerge() {
        Task {
            await MainActor.run(body: {
                mergeList.removeAll()
            })
        }
    }
    
}
private extension Array {
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

