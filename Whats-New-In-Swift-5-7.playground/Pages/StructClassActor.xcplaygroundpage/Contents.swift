//: [Previous](@previous)

/*:
 Copied from Nick Sarno
 
 [Treads / Stacks / Heap](https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/)
 
 Links:
 * https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct/
 * https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 * https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 * https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 * https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 * https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 * https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 * https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99
 
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe (by default)
 - When you assign or pass reference type a new reference to original instance will be created (pointer)
 
 - - - - - - - - - - - - - -
 
 STACK:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack!
 
 HEAP:
 - Stores Reference types
 - Shared across threads!
 
 - - - - - - - - - - - - - -
 
 STRUCT:
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap!
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 - - - - - - - - - - - - - -
 
 Structs: Data Models, Views
 
 Classes: ViewModels
 
 Actors: Shared 'Manager' and 'Data Stores'
 
 
 */

import Foundation
import SwiftUI
import PlaygroundSupport

var greeting = "Actors"

actor DataMananger {
    func getDataFromDatabase() {} // this is thread safe
}

/*: Your ViewModel must be a class to conform to ObservableObject */
class currentViewModel : ObservableObject {
    @Published var info: String = "my Info"
    
    init(){
        print("ViewModel Init")
    }
}

/*:  Classes */

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

private func classTest1() {
    print("classTest1")
    let objectA = MyClass(title: "Starting title!")
    print("ObjectA: ", objectA.title)
    
    print("Pass the REFERENCE of objectA to objectB.")
    let objectB = objectA
    print("ObjectB: ", objectB.title)
    
    objectB.title = "Second title!"
    print("ObjectB title changed.")
    
    print("ObjectA: ", objectA.title)
    print("ObjectB: ", objectB.title)
}
classTest1()
printDivider()

private func classTest2() {
    print("classTest2")
    
    let class1 = MyClass(title: "Title1")
    print("Class1: ", class1.title)
    class1.title = "TitleClass1"
    print("Class1: ", class1.title)
    
    let class2 = MyClass(title: "Title2")
    print("Class2: ", class2.title)
    class2.updateTitle(newTitle: "TitleClass2")
    print("Class2: ", class2.title)
    
    
}
classTest2()
printDivider()

/*: Structs */

struct MyStruct {
    var title: String
}

struct MyStructLet {
    let title: String
}

// Updating a struct creats a new struct.
private func structTest1() {
    
    let structA = MyStruct(title: "Starting title!")
    print("StructA: ", structA.title)
    
    print("Pass the VALUES of structA to structB.")
    var structB = structA
    print("StructB: ", structB.title)
    
    structB.title = "Second title!"
    print("StructB title changed.")
    
    print("StructA: ", structA.title)
    print("StructB: ", structB.title)
    
}

structTest1()
printDivider()

// Immutable struct
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

private func structTest2() {
    print("structTest2")
    
    var structLet = MyStructLet(title: "Title1.1")
    print("Struct1: ", structLet.title)
    // structLet.title = "Title1.2" // Uncommnet to see error
    print("Struct1: ", structLet.title)
    
    let structLet1 = MyStruct(title: "Title1.1")
    print("Struct1: ", structLet1.title)
    // structLet1.title = "Title1.2" // Uncomment to see errro
    print("Struct1: ", structLet1.title)
    
    var struct1 = MyStruct(title: "Title1.1")
    print("Struct1: ", struct1.title)
    struct1.title = "Title1.2"
    print("Struct1: ", struct1.title)
    
    var struct2 = CustomStruct(title: "CustomTitle2.1")
    print("Struct2: ", struct2.title)
    struct2 = CustomStruct(title: "CustomTitle2.2")
    print("Struct2: ", struct2.title)
    
    var struct3 = CustomStruct(title: "CustomTitle3.1")
    print("Struct3: ", struct3.title)
    struct3 = struct3.updateTitle(newTitle: "CustomTitle3.2")
    print("Struct3: ", struct3.title)
    
    var struct4 = MutatingStruct(title: "MutatingTitle1.1")
    print("Struct4: ", struct4.title)
    struct4.updateTitle(newTitle: "MutatingTitle2.1")
    print("Struct4: ", struct4.title)
}

structTest2()
printDivider()

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

private func actorTest1() {
    Task {
        print("actorTest1")
        let objectA = MyActor(title: "Starting title!")
        await print("ObjectA: ", objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB.")
        let objectB = objectA
        await print("ObjectB: ", objectB.title)
        
        await objectB.updateTitle(newTitle: "Second title!")
        print("ObjectB title changed.")
        
        await print("ObjectA: ", objectA.title)
        await print("ObjectB: ", objectB.title)
    }
}


/*struct MyView : View {
 var body :some View {
 Text("hi")
 }
 }*/

//PlaygroundPage.current.setLiveView(MyView())

// Use asyncImage to load our image

private func printDivider() {
    print("""
    
     - - - - - - - - - - - - - - - - -
    
    """)
}
//: [Next](@next)
