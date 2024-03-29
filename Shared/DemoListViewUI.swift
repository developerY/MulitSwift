//
//  ContentView.swift
//  Shared
//
//  Created by iOS Developer on 8/15/21.
//

import SwiftUI
import CoreData

struct DynamicListViewUI: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
            NavigationView {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                        } label: {
                            Text(item.timestamp!, formatter: itemFormatter)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                Text("Select an item")
            }
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ZipMergeViewUI: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            HStack {
                Button("get zip"){
                    viewModel.taskZip()
                }.buttonStyle(.borderedProminent)
                Button("delete zip"){
                    viewModel.deleteZip()
                }.foregroundColor(.red)
            }
            List {
                ForEach(viewModel.zipList, id:\.self) { str in
                    Text(str)
                }
            }
            Spacer()
            HStack {
                Button("get merge"){
                    print("call merge")
                    viewModel.taskMerge()
                }.buttonStyle(.borderedProminent)
                Button("delete merge"){
                    viewModel.deleteMerge()
                }.foregroundColor(.red)
            }
            List {
                ForEach(viewModel.mergeList, id:\.self) { num in
                    Text("This is the merge \(num)")
                }
            }
            
            
        }
    }
}

struct DemoListViewUI: View {
    
    var body: some View {
        
        VStack {
            ZipMergeViewUI()
            DynamicListViewUI()
        }
        
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentViewList_Previews: PreviewProvider {
    static var previews: some View {
        DemoListViewUI().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
