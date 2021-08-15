//
//  MulitSwiftApp.swift
//  Shared
//
//  Created by iOS Developer on 8/15/21.
//

import SwiftUI

@main
struct MulitSwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
