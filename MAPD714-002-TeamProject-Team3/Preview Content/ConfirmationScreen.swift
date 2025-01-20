//
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

// The ConfirmationScreen view displays the order confirmation details
struct ConfirmationScreen: View {
    
    // CoreData context used for managing and fetching data
    @Environment(\.managedObjectContext) private var viewContext
    
    // State variables to store customer info, product details, and order status
    @State private var customerInfo: CustomerInfo?
    @State private var product: Product?
    @State private var orderSaved = false
    @State private var navigateToPreviousOrders = false
    @State private var errorMessage: String?
    @State private var hasSavedOrder = false
    
    // OrderDetails passed from the previous screen to show the details
    var orderDetails: OrderDetails
    
    // The main body of the ConfirmationScreen view
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Confirmation Header Section
                confirmationHeader
                
                // Display customer information if available
                if let info = customerInfo {
                    orderSummaryView(info: info)
                } else {
                    Text("No customer information available.")
                        .foregroundColor(.red)
                }
                
                // Display product details if available
                if let product = product {
                    productDetailsView(product: product)
                } else {
                    Text("No product details available.")
                        .foregroundColor(.red)
                }
                
                // Display error message if there is any
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Navigation links to navigate to Previous Orders or Profile view
                NavigationLink(destination: PreviousOrdersView(), isActive: $navigateToPreviousOrders) {
                    Text("View Previous Orders")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                NavigationLink(destination: ProfileView().navigationBarBackButtonHidden(true)) {
                    Text("Return to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(
            // Gradient background from blue to purple
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                           startPoint: .top,
                           endPoint: .bottom)
        )
        .edgesIgnoringSafeArea(.all) // Ignore safe area to cover full screen
        .navigationTitle("Order Confirmation") // Set navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Use inline title mode
        .onAppear {
            // Fetch customer and product data when the screen appears
            fetchCustomerAndProductData()
            
            // Create and save order only if it hasn't been saved yet
            if !hasSavedOrder {
                createAndSaveOrder()
                hasSavedOrder = true // Mark as saved to avoid duplicate saving
            }
        }
    }
    
    // Confirmation header displaying success message and a checkmark icon
    private var confirmationHeader: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("Your phone order has been successfully completed!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding(.top, 150)
    }

    // View for displaying the order summary (customer details)
    private func orderSummaryView(info: CustomerInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Customer name and delivery address
            summaryItem(title: "Customer", value: info.fullName)
            summaryItem(title: "Delivery Address", value: "\(info.streetAddress), \(info.city), \(info.province), \(info.country)")
        }
        .padding()
        .background(Color.white.opacity(0.1)) // Semi-transparent background
        .cornerRadius(12)
    }

    // View for displaying product details (phone information)
    private func productDetailsView(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Product Details")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Phone make, model, color, storage, and price
            summaryItem(title: "Make", value: product.phoneMake ?? "N/A")
            summaryItem(title: "Model", value: product.phoneModel ?? "N/A")
            summaryItem(title: "Color", value: product.phoneColor ?? "N/A")
            summaryItem(title: "Storage", value: product.storageCapacity ?? "N/A")
            summaryItem(title: "Price", value: String(format: "$%.2f", product.price))
        }
        .padding()
        .background(Color.white.opacity(0.1)) // Semi-transparent background
        .cornerRadius(12)
    }

    // Helper function for creating a summary item (key-value pair)
    private func summaryItem(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.white.opacity(0.8)) // Title in lighter color
            Spacer() // To push the value to the right
            Text(value).foregroundColor(.white).fontWeight(.medium) // Value in bold
        }
    }

    // Fetch customer and product data from CoreData and populate the state variables
    private func fetchCustomerAndProductData() {
        // Fetch customer data from Core Data using logged-in user's email
        if let email = UserDefaults.standard.string(forKey: "loggedInUserEmail") {
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)

            do {
                let users = try viewContext.fetch(fetchRequest)

                if let user = users.first {
                    customerInfo = CustomerInfo(
                        fullName: user.fullName ?? "",
                        streetAddress: user.address ?? "",
                        city: user.city ?? "",
                        province: user.province ?? "",
                        country: user.country ?? "",
                        phoneNumber: user.telephone ?? "",
                        emailAddress: user.email ?? ""
                    )
                    
                    // Save user ID to UserDefaults for future use
                    if let userId = user.customerId {
                        UserDefaults.standard.set(userId.uuidString, forKey: "loggedInUserId")
                    } else {
                        errorMessage = "User ID is missing."
                    }

                } else {
                    errorMessage = "User not found for email \(email)"
                }
                
            } catch {
                errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "No logged-in user email found"
        }

        // Fetch product data based on the provided product ID
        let productFetchRequest = Product.fetchRequest()
        productFetchRequest.predicate = NSPredicate(format: "productId == %@", orderDetails.productId as CVarArg)

        do {
            let products = try viewContext.fetch(productFetchRequest)

            if let fetchedProduct = products.first {
                product = fetchedProduct
            } else {
                errorMessage = "Product not found for ID \(orderDetails.productId)"
            }

        } catch {
            errorMessage = "Failed to fetch product data: \(error.localizedDescription)"
        }
    }

    // Create and save the order to Core Data
    private func createAndSaveOrder() {
        guard let customerInfo = customerInfo,
              let product = product else {
            errorMessage = "Missing customer or product information"
            return
        }

        guard let userIdString = UserDefaults.standard.string(forKey: "loggedInUserId"),
              let userId = UUID(uuidString: userIdString),
              let productId = product.productId else {
            errorMessage = "Missing user ID or product ID"
            return
        }

        // Check if the order already exists for the user and product
        let existingOrders = OrderManager.shared.fetchOrdersForUser(userId: userId, context: viewContext)
        
        if existingOrders.contains(where: { $0.product?.productId == productId }) {
            errorMessage = ""
            return
        }

        // Attempt to create and save a new order
        if let newOrder = OrderManager.shared.createOrder(
            userId: userId,
            productId: productId,
            totalAmount: product.price,
            status: "Confirmed",
            context: viewContext) {

            orderSaved = true
            errorMessage = nil
        } else {
            errorMessage = "Failed to save order"
        }
    }
}

