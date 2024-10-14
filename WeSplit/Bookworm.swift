//
//  Bookworm.swift
//  WeSplit
//
//  Created by sailesh sirari on 10/10/24.
//


import SwiftUI
import SwiftData


struct BookWormApp: App {
    
    @Environment(\.modelContext) var modelContext
    @Query var books: [Book]

    @State private var showingAddScreen = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Text("Count: \(books.count)")
                    .navigationTitle("Bookworm")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add Book", systemImage: "plus") {
                                showingAddScreen.toggle()
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddScreen) {
                        AddBookView()
                    }
            }
        }.modelContainer(for: Book.self)
    }
}


