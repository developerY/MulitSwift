/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# Async sequences

[SE-0298](https://github.com/apple/swift-evolution/blob/main/proposals/0298-asyncsequence.md) introduces the ability to loop over asynchronous sequences of values using a new `AsyncSequence` protocol. This is helpful for places when you want to process values in a sequence as they become available rather than precomputing them all at once – perhaps because they take time to calculate, or because they aren’t available yet.

Using `AsyncSequence` is almost identical to using `Sequence`, with the exception that your types should conform to `AsyncSequence` and `AsyncIterator`, and your `next()` method should be marked `async`. When it comes time for your sequence to end, make sure you send back `nil` from `next()`, just as with `Sequence`.

For example, we could make a `DoubleGenerator` sequence that starts from 1 and doubles its number every time it’s called:
*/
import SwiftUI

struct DoubleGenerator: AsyncSequence {
    typealias Element = Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var current = 1
    
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
func printAllDoubles() async {
    for await number in DoubleGenerator() {
        print(number)
    }
}

print("We start")
Task.init {await printAllDoubles()}
print("Done but still running ...")
   
/*:
The `AsyncSequence` protocol also provides default implementations of a variety of common methods, such as `map()`, `compactMap()`, `allSatisfy()`, and more. For example, we could check whether our generator outputs a specific number like this:
*/
let doubles = DoubleGenerator()

func containsExactNumber() async {
    let match = await doubles.contains(16_777_216)
    print("We found a match", match)
}

func containsEvenNumber() async {
    let sum = await doubles.reduce(0, +)
    print("Sum val ", sum)
}

sleep(2)

Task.init {
    await containsExactNumber()
    await containsEvenNumber()
}
/*:
Again, you need to be in an async context to use this.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
