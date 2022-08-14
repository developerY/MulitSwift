//: [Previous](@previous)

import Foundation
import SwiftUI


class CounterClass {
    private var value = 0
    
    func getVal() -> Int {return  value}
    func increment() {value = value + 1}
    func dec() {value = value - 1}
    
}
let counterClass = CounterClass()


for _ in 1...100 {
    counterClass.increment() // data race

    Task.detached {
        counterClass.increment() // data race
        counterClass.dec() // data race
    }
    
    counterClass.dec() // data race

    Task.detached {
        counterClass.increment() // data race
        counterClass.dec() // data race
    }
}
print("Counter Class", counterClass.getVal())


sleep(2)

struct CounterStruct {
    private var value = 0

    func getVal() -> Int {return  value}
    mutating func increment() {value = value + 1}
    mutating func dec() {value = value - 1}
    
}

let counterStruct = CounterStruct()

Task.detached {
    var counter = counterStruct
    counter.increment() // always prints 1
    counter.dec() // data race

}

Task.detached {
    var counter = counterStruct
    counter.increment() // always prints 1
    counter.dec() // data race

}
print("Counter Struct", counterStruct.getVal())

sleep(2)

actor CounterActor {
    var value = 0
    
    func printVal() -> Int { return value }

    func increment() {value = value + 1}
    func dec(){value = value - 1}
    
}

let counterActor = CounterActor()

for _ in 1...10 {
    
    Task.detached {
        await counterActor.increment() // always prints 1
    }
    Task.detached {
        await counterActor.increment() // always prints 1
        await counterActor.dec() // data race
        
    }
    
    Task.detached {
        await counterActor.dec() // always prints 1
    }

    Task.detached {
        await counterActor.increment() // always prints 1
        await counterActor.dec() // data race
        
    }
}
sleep(2)

Task {
    await print("Counter Actor", counterActor.printVal())
}




//: [Next](@next)
