/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Async sequences

[SE-0298](https://github.com/apple/swift-evolution/blob/main/proposals/0298-asyncsequence.md) introduces the ability to loop over asynchronous sequences of values using a new `AsyncSequence` protocol. This is helpful for places when you want to process values in a sequence as they become available rather than precomputing them all at once – perhaps because they take time to calculate, or because they aren’t available yet.

Using `AsyncSequence` is almost identical to using `Sequence`, with the exception that your types should conform to `AsyncSequence` and `AsyncIterator`, and your `next()` method should be marked `async`. When it comes time for your sequence to end, make sure you send back `nil` from `next()`, just as with `Sequence`.

For example, we could make a `DoubleGenerator` sequence that starts from 1 and doubles its number every time it’s called:
*/
// Just like sequence
// Iteration uses Swift Concurrency
// Interator can Throw
// It has map / filter / reduce

//https://github.com/apple/swift-async-algorithms/tree/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides


import SwiftUI
// iOS 13.0+
/// An AsyncSequence resembles the Sequence type — offering a list of values you can step through one at a time — and adds asynchronicity.
struct DoubleGenerator: AsyncSequence {
    typealias Element = Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var current = 1
    
        // meets protocol
        mutating func next() async -> Int? {
            defer { current &*= 2 }
    
            if current < 0 {
                //print(current) overflow turns negative
                return nil
            } else {
                return current
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator()
    }
}
/*:
**Tip:** If you just remove “async” from everywhere it appears in that code, you have a valid `Sequence` doing exactly the same thing – that’s how similar these two are.

Once you have your asynchronous sequence, you can loop over its values by using `for await` in an async context, like this:
*/
func printAllDoubles() async -> [Int] {
    var nums: [Int] = []
    for await number in DoubleGenerator() {  // FOR AWAIT !!! asynchronous for loop!
        nums.append(number)
    }
    // It could wait forever here ...
    return nums.filter({$0 % 4 == 0})  // Filter
}

print("We start")
var myNums:[Int] = []
Task {
    myNums = await printAllDoubles()
    print("\nPrinting numbers:")
    myNums.forEach{ num in
        print(num)
    }
}
print("Done but still running ... and printing nothing !!! \(myNums)") // FIXME: We get nothing here!

/*:
The `AsyncSequence` protocol also provides default implementations of a variety of common methods, such as `map()`, `compactMap()`, `allSatisfy()`, and more. For example, we could check whether our generator outputs a specific number like this:
*/
let doubles = DoubleGenerator()

func containsExactNumber() async {
    let match = await doubles.contains(16_777_216)
    print("We found a match", match)
}

func summingNumbers() async {
    let sum = await doubles.reduce(0, +)  // REDUCE
    print("Sum val ", sum)
}

func mapNumbers() {
    let twoBigger = doubles.map { value in
        return
    }
    print("Map of doubles \(twoBigger)")
}

print("\n\n\n")
// MARK: Summing Numbers
mapNumbers()
Task {
    await summingNumbers()
    await containsExactNumber()
    //await mapNumbers()
}



// Async Publisher

// Async Stream


// Async Algorithums
// Processing values over time
// Zip

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

for await item in b.send() {  // FOR AWAIT !!! asynchronous for loop!
    print(item)
}
/*
for try await nums in merge(a.send(),b.send(), c.send()) {
    print("num")
}
let appleFeed = URL(string: "http://www.example.com/ticker?symbol=AAPL")!.lines
let nasdaqFeed = URL(string: "http://www.example.com/ticker?symbol=^IXIC")!.lines

for try await (apple, nasdaq) in zip(appleFeed, nasdaqFeed) {
  print("APPL: \(apple) NASDAQ: \(nasdaq)")
}
for try await ticker in merge(appleFeed, nasdaqFeed) {
  print(ticker)
}

for try await (num1,num2) in zip(a.send(),b.send(), c.send()) {
    try await print("\(num1)")
}
 */

sleep(20)
/*:
Again, you need to be in an async context to use this.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
