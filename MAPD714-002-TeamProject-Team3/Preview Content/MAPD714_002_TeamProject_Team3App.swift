//
//  MAPD714_002_TeamProject_Team3App.swift
//  MAPD714-002_TeamProject_Team3
//
//  Created by Team 3
//  - Ashna Paul (301479554)
//
//  - Aditya Janjanam (301357523)
//  Description: This is the entry point of the application where the SwiftUI App lifecycle begins. It sets up the environment and Core Data persistence layer.
//
//  Version: 1.0
//

import SwiftUI
import CoreData

// Main entry point for the application
@main
struct MAPD714_002_TeamProject_Team3App: App {
    
    // PersistenceController instance to manage Core Data setup
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            // MainScreen is the first screen that appears when the app launches.
            // It gets the Core Data context (viewContext) from the environment
            MainScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// PersistenceController: Responsible for setting up Core Data stack and providing access to the managed object context
struct PersistenceController {
    
    // Shared instance for the PersistenceController (singleton pattern)
    static let shared = PersistenceController()
  
    // NSPersistentContainer is the Core Data container that manages the model and context
    let container: NSPersistentContainer

    // Initializer to configure the persistent container
    init(inMemory: Bool = false) {
        // Initialize the NSPersistentContainer with the name of the Core Data model ("Model")
        container = NSPersistentContainer(name: "Model")
        
        // In-memory storage option (useful for testing and temporary data)
        if inMemory {
            // Directly store the data in memory instead of a physical file
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Load the persistent stores
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // If there is an error loading the stores, log the error and stop execution
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

