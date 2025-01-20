//
//  ProductManager.swift
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

import CoreData

// Singleton class for managing products in Core Data
class ProductManager {
    
    // Shared instance to ensure only one instance of ProductManager is used
    static let shared = ProductManager()
    
    // Private initializer to enforce singleton usage
    private init() {}
    
    // Method to create a new product and save it to Core Data
    // Parameters:
    // - phoneMake: The brand of the phone (e.g., "Apple")
    // - phoneModel: The model name/number of the phone (e.g., "iPhone 13")
    // - phoneColor: The color of the phone (e.g., "Red")
    // - storageCapacity: The storage capacity of the phone (e.g., "128GB")
    // - price: The price of the phone (e.g., 999.99)
    // - context: The Core Data managed object context used to interact with the database
    // Returns: A Product object if successful, or nil if there was an error
    func createProduct(phoneMake: String, phoneModel: String, phoneColor: String, storageCapacity: String, price: Double, context: NSManagedObjectContext) -> Product? {
        // Create a new product instance
        let product = Product(context: context)
        
        // Assign values to the product's properties
        product.productId = UUID() // Generate a unique ID for the product
        product.phoneMake = phoneMake
        product.phoneModel = phoneModel
        product.phoneColor = phoneColor
        product.storageCapacity = storageCapacity
        product.price = price
        
        // Try to save the new product to Core Data
        do {
            try context.save() // Save context to persist data
            return product // Return the newly created product
        } catch {
            // If there's an error saving the context, print the error and return nil
            print("Failed to create product: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Method to fetch all products from Core Data
    // Parameters:
    // - context: The Core Data managed object context used to interact with the database
    // Returns: An array of Product objects, or an empty array if there was an error
    func fetchProducts(context: NSManagedObjectContext) -> [Product] {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest() // Create a fetch request to retrieve all products
        
        do {
            return try context.fetch(fetchRequest) // Fetch the products from Core Data
        } catch {
            // If there's an error fetching products, print the error and return an empty array
            print("Failed to fetch products: \(error.localizedDescription)")
            return [] // Return an empty array in case of error
        }
    }
    
    // Method to update an existing product's details
    // Parameters:
    // - product: The Product object to be updated
    // - phoneMake: The updated brand of the phone
    // - phoneModel: The updated model of the phone
    // - phoneColor: The updated color of the phone
    // - storageCapacity: The updated storage capacity of the phone
    // - price: The updated price of the phone
    // - context: The Core Data managed object context used to interact with the database
    // Returns: True if the update was successful, false if there was an error
    func updateProduct(_ product: Product, phoneMake: String, phoneModel: String, phoneColor: String, storageCapacity: String, price: Double, context: NSManagedObjectContext) -> Bool {
        // Update the product's properties with the new values
        product.phoneMake = phoneMake
        product.phoneModel = phoneModel
        product.phoneColor = phoneColor
        product.storageCapacity = storageCapacity
        product.price = price
        
        // Try to save the updated product to Core Data
        do {
            try context.save() // Save context to persist changes
            return true // Return true to indicate the update was successful
        } catch {
            // If there's an error saving the context, print the error and return false
            print("Failed to update product: \(error.localizedDescription)")
            return false
        }
    }
    
    // Method to delete a product from Core Data
    // Parameters:
    // - product: The Product object to be deleted
    // - context: The Core Data managed object context used to interact with the database
    // Returns: True if the deletion was successful, false if there was an error
    func deleteProduct(_ product: Product, context: NSManagedObjectContext) -> Bool {
        // Delete the product from the context
        context.delete(product)
        
        // Try to save the context to persist the deletion
        do {
            try context.save() // Save context to persist changes
            return true // Return true to indicate the deletion was successful
        } catch {
            // If there's an error saving the context, print the error and return false
            print("Failed to delete product: \(error.localizedDescription)")
            return false
        }
    }
}

