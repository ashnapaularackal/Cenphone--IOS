//
//  ReadData.swift
//  MAPD714-003_TeamProject_Team3
//
//  CenPhone Mobile Shopping App
//  Created by Team 3
//  - Ashna Paul (301479554)
//  - Aditya Janjanam (301357523)
//
//  Date: November 25, 2024
//  Version: 1.0
//

import SwiftUI
import CoreData

// Class responsible for reading data from Core Data and performing authentication
class ReadData {

    // Method to authenticate a user based on email and password
    // Parameters:
    // - email: The email entered by the user (String)
    // - password: The password entered by the user (String)
    // - viewContext: The Core Data managed object context used to interact with the database
    // Returns: A Boolean value indicating whether the user is authenticated (true if valid, false if invalid)
    public func authenticator(email: String, password: String, viewContext: NSManagedObjectContext) -> Bool {
        
        // Create a fetch request to query the 'User' entity from Core Data
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        // Set a predicate to filter users by the provided email and password
        fetchRequest.predicate = NSPredicate(format: "email == %@ && password == %@", email, password)
        
        do {
            // Perform the fetch request to retrieve users matching the email and password
            let users = try viewContext.fetch(fetchRequest)
            
            // Return true if any user matching the email and password is found, otherwise false
            return !users.isEmpty
            
        } catch {
            // If there is an error fetching the user (e.g., Core Data issue), print the error and return false
            print("Failed to fetch user: \(error.localizedDescription)")
            return false
        }
    }
}

