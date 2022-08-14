/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Effectful read-only properties

[SE-0310](https://github.com/apple/swift-evolution/blob/main/proposals/0310-effectful-readonly-properties.md) upgrades Swift’s read-only properties to support the `async` and `throws` keywords, either individually or together, making them significantly more flexible. 

To demonstrate this, we could create a `BundleFile` struct that attempts to load the contents of a file in our app’s resource bundle. Because the file might not be there, might be there but can’t be read for some reason, or might be readable but so big it takes time to read, we could mark the `contents` property as `async throws` like this:
*/
import Foundation
import SwiftUI

enum FileError: Error {
    case missing, unreadable
}

struct BundleFile {
    let filename: String
    let stringToSave = "The string I want to save"

    
    var contents: String {
        get async throws {
            guard let url = Bundle.main.url(forResource: filename /*try nil*/, withExtension: nil) else {
                throw FileError.missing
            }
            
            
            do {
                return try String(contentsOf: url)
            } catch {
                throw FileError.unreadable
            }
        }
    }
}
/*:
Because `contents` is both async and throwing, we must use `try await` when trying to read it:
*/
func printHighScores() async throws {
    let file = BundleFile(filename: "highscores")
    try await print("This is the contents = '\(file.contents)'")
}

Task {
    do {
        print ("High scores bundle", try await printHighScores())
    } catch {
        print("Expected error: \(error).")
    }
}
/*:

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
