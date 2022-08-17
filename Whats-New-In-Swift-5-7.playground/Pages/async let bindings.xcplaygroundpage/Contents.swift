/*:


&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
# `async let` bindings

[SE-0317](https://github.com/apple/swift-evolution/blob/main/proposals/0317-async-let.md) introduces the ability to create and await child tasks using the simple syntax `async let`. This is particularly useful as an alternative to task groups where you’re dealing with heterogeneous result types – i.e., if you want tasks in a group to return different kinds of data.

To demonstrate this, we could create a struct that has three different types of properties that will come from three different async functions:
*/
import Foundation
import SwiftUI

struct UserData {
    let username: String
    let friends: [String]
    let highScores: [Int]
    let ans : Int
}
    
func getUser() async -> String {
    print("Get Name DONE!")
    return "Taylor Swift"
}
    
func getHighScores() async -> [Int] {
    print("Get HS DONE!")
    return [42, 23, 16, 15, 8, 4]
}
    
func getFriends() async -> [String] {
    print("Get Friends DONE!")
    return ["Eric", "Maeve", "Otis"]
}

func fibNum1000() async -> Int {
    let ans = await fib(of: 10)
    print("fib 1000 done")
    return ans
}

// Started first but others end first
func fib(of number: Int) async -> Int {
    if number < 2 { return number }
    async let first = fib(of: number - 2)
    async let second = fib(of: number - 1)
    return  await first + second
}
/*:
If we wanted to create a `User` instance from all three of those values, `async let` is the easiest way – it run each function concurrently, wait for all three to finish, then use them to create our object.

Here’s how it looks:
*/
func printUserDetails() async { // three diff types.
    async let num1001 = fibNum1000() // starts immediate
    async let username = getUser()
    async let scores = getHighScores()
    async let friends = getFriends()

    let user = await UserData(username: username, friends: friends, highScores: scores, /*ans:5*/ ans:num1001)
    
    print("Hello, my name is \(user.username), and I have \(user.friends.count) friends!")
}

Task {
    await printUserDetails()
}
sleep(2)
/*:
**Important:** You can only use `async let` if you are already in an async context, and if you don’t explicitly await the result of an `async let` Swift will implicitly wait for it when exiting its scope.

When working with throwing functions, you *don’t* need to use `try` with `async let` – that can automatically be pushed back to where you await the result. Similarly, the `await` keyword is also implied, so rather than typing `try await someFunction()` with an `async let` you can just write `someFunction()`.

To demonstrate this, we could write an async function to recursively calculate numbers in the Fibonacci sequence. This approach is hopelessly naive because without memoization we’re just repeating vast amounts of work, so to avoid causing everything to grind to a halt we’re going to limit the input range from 0 to 22:
*/
enum NumberError: Error {
    case outOfRange
}

enum TestName :Error {
    case bad
}

func fibonacci(of number: Int) async throws -> Int {
    if number < 0 || number > 22 {
        throw NumberError.outOfRange
    }
    
    if number < 2 { return number }
    async let first = fibonacci(of: number - 2)
    async let second = fibonacci(of: number - 1)
    return try await first + second // do not need to type::
         //try await first + try await second
}

func getName(tag: Bool) async throws -> String {
    guard tag == true else {throw TestName.bad}
    return "Swift"
}

func getNumber (tag: Bool) async throws -> Int {
    guard tag == true else {throw TestName.bad}
    return 27
}

Task {
    do {
        try await print("Name \(getName(tag: true)) Num \(getNumber(tag: true))")
        print("Name \(try await getName(tag: true)) Num \(try await getNumber(tag: true))")
    } catch {
        print("Error",error)
    }
}
/*:
In that code the recursive calls to `fibonacci(of:)` are implicitly `try await fibonacci(of:)`, but we can leave them off and handle them directly on the following line.

&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
