
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

class CreateData {
    public func registerUser(
        fullName: String,
        address: String,
        city: String,
        province: String, // Added province parameter
        country: String,
        telephone: String,
        email: String,
        username: String,
        password: String,
        confirmPassword: String,
        productDetailsList: [(phoneMake: String, phoneModel: String, phoneColor: String, storageCapacity: String, price: Double)]?, // List of products
        viewContext: NSManagedObjectContext
    ) -> Bool {
        
        // Validate user input
        if fullName.isEmpty || address.isEmpty || city.isEmpty || province.isEmpty || country.isEmpty || telephone.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            print("Validation failed: Some required fields are empty.")
            return false
        }

        // Check if user already exists based on email or username
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ OR username == %@", email, username)

        do {
            let existingUsers = try viewContext.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                print("User already exists with email or username")
                return false
            }
        } catch {
            print("Failed to fetch existing users: \(error.localizedDescription)")
            return false
        }

        // Create new User
        let newUser = User(context: viewContext)
        newUser.customerId = UUID()
        newUser.fullName = fullName
        newUser.address = address
        newUser.city = city
        newUser.province = province // Save province
        newUser.country = country
        newUser.telephone = telephone
        newUser.email = email
        newUser.username = username
        newUser.password = password
        
        // Create and associate Products if product details are provided
        if let productDetailsList = productDetailsList {
            for productDetails in productDetailsList {
                let newProduct = Product(context: viewContext)
                newProduct.productId = UUID()
                newProduct.phoneMake = productDetails.phoneMake
                newProduct.phoneModel = productDetails.phoneModel
                newProduct.phoneColor = productDetails.phoneColor
                newProduct.storageCapacity = productDetails.storageCapacity
                newProduct.price = productDetails.price
                
                // Add product to user's products set and set owner reference
                newUser.addToProducts(newProduct)
                newProduct.owner = newUser // Set back reference to User
            }
        }

        // Save the context with both User and Products (if created)
        do {
            try viewContext.save()
            print("User registered successfully.")
            return true
        } catch {
            print("Failed to register user and save context: \(error.localizedDescription)")
            return false
        }
    }
}
