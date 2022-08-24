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

// MARK: return tuple

// does not throw and has two returns
// protocol Error : Sendable (A type whose values can safely be passed across concurrency domains by copying.)
func getTitle() -> (title: String?, error: Error?) {
    if isTitle {
        return ("NEW TEXT!", nil)
    } else {
        return (nil, ValidationError.tooLong)
    }
}

let isTitle: Bool = true // false
let returnedValue = getTitle()
if let newTitle = returnedValue.title {
    print(newTitle)
} else if let error = returnedValue.error {
    print(error.localizedDescription)
}

// MARK: Return Result

// does not throw but uses the Result iOS 8.0+ (Swift 5.0?)
// "Until Swift 5.0 added the Result type, it was harder to send back errors with completion handlers" - Paul
func getTitle2() -> Result<String, Error> {
    if isTitle2 {
        return .success("NEW TEXT!")
    } else {
        return .failure(ValidationError.tooShort)
    }
}

let isTitle2: Bool = true // false
let result = getTitle2()
switch result {
case .success(let newTitle):
    print(newTitle)
case .failure(let error):
    print(error.localizedDescription)
}


// MARK: Throws -- try?

// throws
func getTitle3() throws -> String {
    if isTitle3 { // isFalse
        return "NEW TEXT!"
    } else {
        throw ValidationError.tooShort
    }
}

// must use try? to see the all throws
func getTitle4() throws -> String {
    if isTitle4 {
        return "FINAL TEXT!"
    } else {
        throw ValidationError.tooLong
    }
}

// return here only once.
let isTitle3 = true // false
let isTitle4 = true // false
do {
    let newTitle:String? = try getTitle3() // try? will continue to execute after failure
    if let newTitle = newTitle {
        print(newTitle)
    }
    
    let finalTitle = try getTitle4()
    print(finalTitle)
} catch {
    print(error.localizedDescription)
}

do {
    try getTitle3()
} catch {
    print(error.localizedDescription)
}

do {
    try? getTitle4()
} catch { //'catch' block is unreachable because no errors are thrown in 'do' block
    print(error.localizedDescription)
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

// build for SwiftUI View
print ("always returns a string =  \(alwaysGetTitle())")


// what if we throw?

func alwaysThrows() throws {
    print("throwing")
    throw ValidationError.tooLong
}

func callThowFunc() throws {
    // do not need do{}catch{} if throwing
    // do {
    try alwaysThrows()
    // } catch { print("\(error)") throw ValidationError.tooLong }
}

// try callThowFunc()

//: [Next](@next)
