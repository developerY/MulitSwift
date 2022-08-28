/*:
 
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 # Structured concurrency
 
 [SE-0304](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md) introduces a whole range of approaches to execute, cancel, and monitor concurrent operations in Swift, and builds upon the work introduced by async/await and async sequences.
 
 For easier demonstration purposes, here are a couple of example functions we can work with – an async function to simulate fetching a certain number of weather readings for a particular location, and a synchronous function to calculate which number lies at a particular position in the Fibonacci sequence:
 */
import Foundation
import SwiftUI
import PlaygroundSupport

enum LocationError: Error {
    case unknown_location
}

func waitDoneBeforeNext() { // do not put async here :-)
    sleep(2) // wait for 5 sec before letting next func start
    print("\n\n")
}

/*
 Network call
 */
func getWeatherReadings(for location: String) async throws -> [Double] {
    switch location {
    case "London":
        return (1...10).map { _ in Double.random(in: 6...26) }
    case "Rome":
        return (1...10).map { _ in Double.random(in: 10...32) }
    case "San Francisco":
        return (1...10).map { _ in Double.random(in: 12...20) }
    default:
        throw LocationError.unknown_location
    }
}

/* Long running task */
func fibonacci(of number: Int) -> Int {
    var first = 0
    var second = 1
    
    for _ in 0..<number {
        let previous = first
        first = second
        second = previous + first
    }
    
    return first
}
/*:
 The simplest async approach introduced by structured concurrency is the ability to use the `@main` attribute to go immediately into an async context, which is done simply by marking the `main()` method with `async`, like this:
 */

// "In swift you can still use main.swift and it will be the entry point for your app."
// @main - Adding this annotation to a class, struct, or enum means that it contain the entry point for the app and it should provide a static main function.
// unless you file is called Main.swift
// "You can’t mix these approaches. A program can only have one entry point. If you have a main.swift you cannot also use @main." - useyourloaf
//@main (Swift 5.3)
struct Main {
    static func main() async throws {
        let readings = try await getWeatherReadings(for: "London")
        print("Readings are: \(readings)")
    }
}
/*:
 **Tip:** Before release, it should also be possible to run async code directly in main.swift, without using the `@main` attribute.
 
 The main changes introduced by structured concurrency are backed by two new types, `Task` and `TaskGroup`, which allow us to run concurrent operations either individually or in a coordinated way.
 
 In its simplest form, you can start concurrent work by creating a new `Task` object and passing it the operation you want to run. This will start running on a background thread immediately, and you can use `await` to wait for its finished value to come back.
 
 So, we might call `fibonacci(of:)` many times on a background thread, in order to calculate the first 5 numbers in the sequence:
 */
func printFibonacciSequence() async -> String {
    
    let task1 = Task { () -> [Int] in  // takes void and returns an array of Int
        var numbers = [Int]()
        for i in 0..<5 {
            let result = fibonacci(of: i)
            numbers.append(result)
        }
        return numbers // Task returns values when asked but already running.
    }
    
    let result1 = await task1.value // let task1: Task<[Int], Never>
    
    
    print("Fibonacci sequence (5): \(result1)")
    return "DONE"
}

func returnDemo() {
    print("we start Fib(5) task")
    Task {
        await print("run Fib(5) ", printFibonacciSequence())
        print("now we can use the results")
    }
    print("we end but the code is still running so we can not use the results here  :-)")
}
// returnDemo() //waitDoneBeforeNext()
/*:
 As you can see, I’ve needed to explicitly write `Task { () -> [Int] in` so that Swift understands that the task is going to return, but if your task code is simpler that isn’t needed. For example, we could have written this and gotten exactly the same result:
 */
let task1 = Task {
    (0..<12).map(fibonacci) // understood return
}


func noReturnDemo() {
    Task {
        print("running task1 Fib(12) with no return", await task1.value)
    }
}
// noReturnDemo() waitDoneBeforeNext()

/*:
 Again, the task starts running as soon as it’s created, and the `printFibonacciSequence()` function will continue running on whichever thread it was while the Fibonacci numbers are being calculated.
 
 **Tip:** Our task's operation is a non-escaping closure because the task immediately runs it rather than storing it for later, which means if you use `Task` inside a class or a struct you don’t need to use `self` to access properties or methods.
 
 When it comes to reading the finished numbers, `await task1.value` will make sure execution of `printFibonacciSequence()` pauses until the task’s output is ready, at which point it will be returned. If you don’t actually care what the task returns – if you just want the code to start running and finish whenever – you don’t need to store the task anywhere.
 
 For task operations that throw uncaught errors, reading your task’s `value` property will automatically also throw errors. So, we could write a function that performs two pieces of work at the same time then waits for them both to complete:
 */
func runMultipleCalculations() async throws {
    let task1 = Task { // Started here
        (0..<7).map(fibonacci)
    }
    
    let task2 = Task { // Started here
        try await getWeatherReadings(for: "Rome")
    }
    
    let task3 = Task { // Started here
        try await getWeatherReadings(for: "Does not exist")
    }

    let value1 = await task1.value // value 1 is ready to use
    let value2 : [Double] = try await task2.value // value 2 is ready to use
    let result1 : Result<[Int], Never> = await task1.result
    let result2 : Result<[Double], Error> = await task2.result
    print("Fibonacci (7): r \(result1) v \(value1) \n Rome weather: v \(value2)")
    
    // becuase throws do not need a do block
    let result3 = try await task3.value // resualt 3 is ready to use with error
    print("result3 \(result3)")
}

func runMultiTaskDemo() {
    Task {
        // catch not error?
        //do {
            try await runMultipleCalculations()
        //} catch { print("\(error)")}
    }
}
// runMultiTaskDemo() // waitDoneBeforeNext()
/*:
 Swift provides us with the built-in task priorities of `high`, `default`, `low`, and `background`. The code above doesn’t specifically set one so it will get `default`, but we could have said something like `Task(priority: .high)` to customize that. If you’re writing just for Apple’s platforms, you can also use the more familiar priorities of `userInitiated` in place of high, and `utility` in place of `low`, but you *can’t* access `userInteractive` because that is reserved for the main thread.
 
 As well as just running operations, `Task` also provides us with a handful of static methods to control the way our code runs:
 
 - Calling `Task.sleep()` will cause the current task to sleep for a specific number of nanoseconds. Until something better comes along, this means writing 1_000_000_000 to mean 1 second.
 - Calling `Task.checkCancellation()` will check whether someone has asked for this task to be cancelled by calling its `cancel()` method, and if so throw a `CancellationError`.
 - Calling `Task.yield()` will suspend the current task for a few moments in order to give some time to any tasks that might be waiting, which is particularly important if you’re doing intensive work in a loop.
 
 You can see both sleeping and cancellation in the following code example, which puts a task to sleep for one second then cancels it before it completes:
 */
func cancelSleepingTask() async {
    // Error @frozen struct Task<Success, Failure> where Success : Sendable, Failure : Error
    let task : Task<String, Error> = Task { () -> String in
        print("Starting Sleep/Cancle")
        try await Task.sleep(nanoseconds: 1_000_000_000) // sleep for 1 sec.
        try Task.checkCancellation()
        return "Done"
    }
    
    // The task has started, but we'll cancel it while it sleeps
    task.cancel() // NOTE: Comment out
    
    do {
        let value = try await task.value
        let result = await task.result
        print("Value: \(value) with result \(result)")
    } catch {
        print("Task was cancelled.", error) // NOTE: <--We see this
    }
    
    // do not need do block becuse we are not trying to use the value!
    let result = await task.result
    // await task.value // will cause an error because try is missing
    print("Result \(result)")
    
}

func sleepingDemo() {
    Task {
        print("Calling sleeping/cancle task", await cancelSleepingTask())
    }
}
//sleeping() // waitDoneBeforeNext()


/*:
 In that code, `Task.checkCancellation()` will realize the task has been cancelled and immediately throw `CancellationError`, but that won’t reach us until we attempt to read `task.value`.
 
 **Tip:** Use `task.result` to get a `Result` value containing the task’s success and failure values. For example, in the code above we’d get back a `Result<String, Error>`. This does *not* require a `try` call because you still need to handle the success or failure case.
 
 For more complex work, you should create *task groups* instead – collections of tasks that work together to produce a finished value.
 
 To minimize the risk of programmers using task groups in dangerous ways, they don’t have a simple public initializer. Instead, task groups are created using functions such as `withTaskGroup()`: call this with the body of work you want done, and you’ll be passed in the task group instance to work with. Once inside the group you can add work using the `async()` method, and it will start executing immediately.
 
 **Important:** You should not attempt to copy that task group outside the body of `withTaskGroup()` – the compiler can’t stop you, but you’re just going to make problems for yourself.
 
 To see a simple example of how task groups work – along with demonstrating an important point of how they order their operations, try this:
 */
func printTaskGroupMessage() async {
    let taskGroupString = await withTaskGroup(of: String.self) { group -> String in
        group.addTask { "Hello" } // a closure that returns a String
        
        group.addTask { "From" }
        group.addTask { "A" }
        
        // in the middel
        group.addTask { await printFibonacciSequence() }
        
        group.addTask { "Task" }
        group.addTask { "Group" }
        
        var collected = [String]()
        
        for await value in group {
            // await Task.sleep(2_000_000) // this might scramble the words
            collected.append(value)
        }
        let ans = collected.joined(separator: " ")
        
        return ans
    }
    
    print("This is the collected String: ", taskGroupString)
}

func taskGroupDemo() {
    Task{
        print("Start Task Group Message: ", await printTaskGroupMessage())
    }
}
// taskGroupDemo() // waitDoneBeforeNext()
/*:
 That creates a task group designed to produce one finished string, then queues up several closures using the `async()` method of the task group. Each of those closures returns a single string, which then gets collected into an array of strings, before being joined into one single string and returned for printing.
 
 **Tip:** All tasks in a task group must return the same type of data, so for complex work you might find yourself needing to return an enum with associated values in order to get exactly what you want. A simpler alternative is introduced in a separate Async Let Bindings proposal.
 
 Each call to `async()` can be any kind of function you like, as long as it results in a string. However, although task groups automatically wait for all the child tasks to complete before returning, when that code runs it’s a bit of a toss up what it will print because the child tasks can complete in any order – we’re as likely to get “Hello From Task Group A” as we are “Hello A Task Group From”, for example.
 
 If your task group is executing code that might throw, you can either handle the error directly inside the group or let it bubble up outside the group to be handled there. That latter option is handled using a different function, `withThrowingTaskGroup()`, which must be called with `try` if you haven’t caught all the errors you throw.
 
 For example, this next code sample calculates weather readings for several locations in a single group, then returns the overall average for all locations:
 */
func printAllWeatherReadings() async  { // remove do block. Add throws and try
    let cities = ["London", "Rome", "San Francisco"]
    do {
        print("Calculating average weather…")
        
        let result = try await withThrowingTaskGroup(of: [Double].self) { group -> String in
            group.addTask {
                return try await getWeatherReadings(for: "London")
            }
            
            group.addTask {
                try await getWeatherReadings(for: "Rome")
            }
            
            group.addTask {
                try await getWeatherReadings(for: "San Francisco")
            }
            
            // Uncomment for error
            // group.addTask {try await getWeatherReadings(for: "Not Here")}
            
            for city in cities {
                // all task are same and only need to cancle one time
                group.addTask {
                    try await getWeatherReadings(for: city)
                }
            }
            
            print("\n\nStart for loop")
            for try await city in group { // because they all return the same type
                print("This is the temp \(String(describing: city.first))")
            }
            print("End for loop \n\n")
            
            
            // Convert our array of arrays into a single array of doubles
            let allValues = try await group.reduce([], +)
            
            // Calculate the mean average of all our doubles
            let average = allValues.reduce(0, +) / Double(allValues.count)
            return "Overall average temperature is \(average)"
            
        }
        
        print("Done! \(result)")
    } catch { print("Error calculating data. With error: \(error)", error) }
}

func GroupDemo() {
    Task {
        print("Start Task Weather:", await printAllWeatherReadings())
    }
}
//GroupDemo() // waitDoneBeforeNext()
/*:
 In that instance, each of the calls to `async()` is identical apart from the location string being passed in, so you can use something like `for location in ["London", "Rome", "San Francisco"] {` to call `async()` in a loop.
 
 Task groups have a `cancelAll()` method that cancels any tasks inside the group, but using `async()` afterwards will continue to add work to the group. As an alternative, you can use `asyncUnlessCancelled()` to skip adding work if the group has been cancelled – check its returned Boolean to see whether the work was added successfully or not.
 &nbsp;*/

// MARK: From Nick
let urlStrings = [
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300",
    "https://picsum.photos/300",
]

private func fetchImage(urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw URLError(.badURL)
        }
    } catch {
        throw error
    }
}

struct ContentView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var images: [UIImage] = []
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
                
            }.onAppear {
                Task {
                    images.reserveCapacity(urlStrings.count)
                    try await withThrowingTaskGroup(of: UIImage?.self) { group in
                        for urlString in urlStrings {
                            
                            // all task are same and only need to cancle one time
                            group.addTask {
                                // Might not get all the images "try?"
                                try? await fetchImage(urlString: urlString) // not all images might show up becuase "try?"
                            }
                        }
                        
                        // Async For Loop!!!
                        for try await image in group {
                            if let image = image { // only add images we recieve
                                images.append(image)
                            }
                        }
                    }
                }
                
            }
        }
    }
}

PlaygroundPage.current
    .setLiveView(ContentView())




// lets review task priority
/*Task {
    print(Thread.current)
    print(Task.currentPriority)
}*/


func ShowTasks() {
    Task(priority: .high) {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await Task.yield()
        print("high : \(Thread.current) : \(Task.currentPriority)")
    }
    Task(priority: .userInitiated) {
        print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
    }
    Task(priority: .medium) {
        print("medium : \(Thread.current) : \(Task.currentPriority)")
    }
    Task(priority: .low) {
        print("low : \(Thread.current) : \(Task.currentPriority)")
    }
    Task(priority: .utility) {
        print("utility : \(Thread.current) : \(Task.currentPriority)")
    }
    Task(priority: .background) {
        print("background : \(Thread.current) : \(Task.currentPriority)")
    }
    
    
    //Both have the same priority --
    Task(priority: .low) {
        print("low : \(Thread.current) : \(Task.currentPriority)")
        
        
        Task { // .detached
            print("try detached : \(Thread.current) : \(Task.currentPriority)")
        }
    }
}

/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
