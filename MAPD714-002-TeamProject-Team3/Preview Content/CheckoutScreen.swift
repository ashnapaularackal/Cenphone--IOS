//
//  CheckoutScreen.swift
//  MAPD714-002_TeamProject_Team3
//
//  CenPhone Mobile Shopping App
//  Created by Team 3
//  - Ashna Paul (301479554)
//  - Aditya Janjanam (301357523)
//
//  Date: November 3, 2024
//  Version: 1.0
//

import SwiftUI
import CoreData

// CheckoutScreen is the view that displays the product details and allows the user to proceed to checkout
struct CheckoutScreen: View {
    
    // Core Data context for managing product and order data
    @Environment(\.managedObjectContext) private var viewContext
    
    // The product passed from the previous screen
    var product: Product
    
    // State variable to track whether the product has been saved to CoreData
    @State private var isProductSaved = false
    
    // State variable to hold order details once the product is saved
    @State private var orderDetails: OrderDetails?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Display the checkout information section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Checkout Information")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 100)
                    
                    // Display product details: Model, Price, Storage, Color
                    InfoRow(title: "Model", value: "\(product.phoneMake ?? "") \(product.phoneModel ?? "")")
                    InfoRow(title: "Price", value: String(format: "$%.2f", product.price))
                    InfoRow(title: "Storage", value: product.storageCapacity ?? "")
                    InfoRow(title: "Color", value: product.phoneColor ?? "")
                }
                .padding()
                .background(Color.white.opacity(0.1)) // Background with some opacity for design
                .cornerRadius(15)

                // Navigation link to proceed to the CustomerInfoScreen
                NavigationLink(destination: CustomerInfoScreen(
                    model: "\(product.phoneMake ?? "") \(product.phoneModel ?? "")",
                    price: String(format: "$%.2f", product.price),
                    storage: product.storageCapacity ?? "",
                    color: product.phoneColor ?? "",
                    productId: product.productId ?? UUID() // Default UUID if productId is nil
                )) {
                    Text("Proceed to Checkout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Full width button
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(!isProductSaved) // Disable button until product is saved

                // Show a success message when the product is saved successfully
                if isProductSaved {
                    Text("")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .padding()
        }
        .background(
            // Background gradient from blue to purple
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .edgesIgnoringSafeArea(.all) // Ensure the background covers the full screen
        .navigationBarTitleDisplayMode(.inline) // Inline title style
        .onAppear {
            // Save product data to CoreData when the screen appears
            saveProductToCore()
        }
    }

    // Function to save the product to CoreData and set order details
    private func saveProductToCore() {
        // Call ProductManager to save product to Core Data
        let savedProduct = ProductManager.shared.createProduct(
            phoneMake: product.phoneMake ?? "",
            phoneModel: product.phoneModel ?? "",
            phoneColor: product.phoneColor ?? "",
            storageCapacity: product.storageCapacity ?? "",
            price: product.price,
            context: viewContext
        )

        // If the product is successfully saved, update isProductSaved state and create order details
        if let savedProduct = savedProduct {
            isProductSaved = true
            
            // Create OrderDetails with the saved product's ID
            orderDetails = OrderDetails(
                brand: savedProduct.phoneMake ?? "",
                model: savedProduct.phoneModel ?? "",
                price: String(format: "$%.2f", savedProduct.price),
                storage: savedProduct.storageCapacity ?? "",
                color: savedProduct.phoneColor ?? "",
                customerName: "Customer Name", // Placeholder for actual customer name
                deliveryAddress: "Delivery Address", // Placeholder for actual delivery address
                productId: savedProduct.productId ?? UUID() // Default UUID if nil
            )
            
            // Now you can use the orderDetails as needed in your app (e.g., pass to next screen)
        }
    }
}

// InfoRow is a reusable view to display key-value pairs in the checkout screen
struct InfoRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer() // Push the value to the right
            Text(value)
        }
    }
}

// Preview for CheckoutScreen (for SwiftUI Canvas)
struct CheckoutScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Product for preview purposes
        let mockProduct = Product() // Assuming Product has a default initializer or provide mock data accordingly.
        mockProduct.phoneMake = "Apple"
        mockProduct.phoneModel = "iPhone 13 Pro"
        mockProduct.price = 999.99
        mockProduct.storageCapacity = "256GB"
        mockProduct.phoneColor = "Sierra Blue"
        
        return CheckoutScreen(product: mockProduct) // Use mock product for preview
    }
}

