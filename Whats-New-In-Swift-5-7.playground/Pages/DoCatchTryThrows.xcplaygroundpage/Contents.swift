//: [Previous](@previous)
//
//  DoCatchTryThrows
//
//
// Orig Created by Nick Sarno on 3/31/22.
// Copied by Yours truly (Ash).
//

import Foundation

var greeting = "Do Try"

enum ValidationError: Error {
    case tooShort
    case tooLong
}

class Manager {
    
    let isActive: Bool = false
    let isFalse = false
    
    // does not throw and has two returns
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, ValidationError.tooLong)
        }
    }
    
    // does not throw but uses the Result iOS 8.0+ (Swift 5.0?)
    // "Until Swift 5.0 added the Result type, it was harder to send back errors with completion handlers" - Paul
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(ValidationError.tooShort)
        }
    }
    
    // throws
    func getTitle3() throws -> String {
        if isActive { // isFalse
            return "NEW TEXT!"
        } else {
            throw ValidationError.tooShort
        }
    }
    
    // must use try? to see the all throws
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT!"
        } else {
            throw ValidationError.tooLong
        }
    }
    
    
    func alwaysGetTitle() -> String { // Important to SwiftUI
        // return try getTitle4() // Errors thrown from here are not handled
        
        // type docat
        do {
            return try getTitle4() //Errors thrown from here are not handled because the enclosing catch is not exhaustive
        } catch ValidationError.tooShort {
            return("short error: \(ValidationError.tooShort).")
        } catch ValidationError.tooLong {
            return("long error: \(ValidationError.tooLong).")
        }catch { // this need to be exhaustive becuase you can not have a typed Error
            return("Unexpected error: \(error).")
        }
    }
    // return here only once.
}


let manager = Manager()
do {
    let newTitle:String? = try manager.getTitle3() // try? will continue to execute after failure
    if let newTitle = newTitle {
        print(newTitle)
    }

    let finalTitle = try manager.getTitle4()
    print(finalTitle)
} catch {
    print(error.localizedDescription)
}


/*: does it need a do{}catch() here? */
do {
    try? manager.getTitle4()
}

/*: does it need a do here? */
// build in SwiftUI View
print ("always returns a string =  \(manager.alwaysGetTitle())")


//: [Next](@next)
