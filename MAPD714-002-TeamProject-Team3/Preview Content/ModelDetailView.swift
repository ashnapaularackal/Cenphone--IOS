//
//  ModelDetailView.swift
//  MAPD714-002_TeamProject_Team3
//
//  CenPhone Mobile Shopping App
//  Created by Team 3
//  - Ashna Paul (301479554)
//  - Aarya Savaliya (301473601)
//  - Aditya Janjanam (301357523)
//
//  Date: November 3, 2024
//  Version: 1.0
//

import SwiftUI

// ModelDetailView: Displays the details of a selected phone model
struct ModelDetailView: View {
    // Model data structure containing the phone's information
    var model: (name: String, price: String, imageName: String, storage: [String], colors: [String])

    // State properties to store user selections for storage, color, and carrier
    @State private var selectedStorage: String
    @State private var selectedColor: String
    @State private var selectedCarrier: String = "Bell"
    
    // A dictionary mapping storage options to their respective prices
    private let storagePrices: [String: String] = [
        "64 GB": "$699",
        "128 GB": "$799",
        "256 GB": "$899",
        "512 GB": "$999"
    ]
    
    // Initializer to set the initial values of state properties based on the model
    init(model: (name: String, price: String, imageName: String, storage: [String], colors: [String])) {
        self.model = model
        _selectedStorage = State(initialValue: model.storage.first ?? "128 GB") // Default to the first storage option
        _selectedColor = State(initialValue: model.colors.first ?? "Black") // Default to the first color option
    }

    var body: some View {
        // ScrollView to handle long content that may require scrolling
        ScrollView {
            VStack {
                // Model Image - Display the image of the selected phone model
                Image(model.imageName)
                    .resizable()
                    .scaledToFit() // Scale the image proportionally
                    .frame(width: 100, height: 100) // Set fixed width and height for the image
                    .cornerRadius(15) // Apply rounded corners to the image
                    .padding(.top, 10) // Add padding at the top

                // Model Name - Display the name of the phone model
                Text(model.name)
                    .font(.title)
                    .padding(.top, 10) // Add padding at the top of the text

                // Dynamic Price Display - Show the price based on selected storage
                Text(selectedPrice)
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10) // Add padding below the price label

                // Call to Action - Picker views for selecting storage, color, and carrier
                storagePicker
                colorPicker
                carrierPicker

                // Proceed to Checkout button
                checkoutButton
            }
            .padding() // Add padding around the entire content
        }
        .navigationBarTitleDisplayMode(.inline) // Inline title for better navigation bar appearance
        .background( // Gradient background similar to previous screens
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea() // Ensure the gradient fills the entire screen
        )
    }

    // Calculate the price based on the selected storage option
    private var selectedPrice: String {
        storagePrices[selectedStorage] ?? model.price // Default to model's base price if no match
    }
    
    // Create a product based on the current selections (used for checkout)
    private func createProduct() -> Product {
        let context = PersistenceController.shared.container.viewContext
        let product = Product(context: context)

        // Populate the product with the selected attributes
        product.productId = UUID()
        product.phoneMake = model.name.split(separator: " ").first.map(String.init) ?? "" // Extract the phone make (e.g., Apple)
        product.phoneModel = model.name // Full model name
        product.phoneColor = selectedColor // Selected color
        product.storageCapacity = selectedStorage // Selected storage capacity
        product.price = Double(selectedPrice.replacingOccurrences(of: "$", with: "")) ?? 0.0 // Price after removing '$' symbol

        do {
            try context.save() // Save the product in the Core Data context
        } catch {
            print("Failed to save product: \(error.localizedDescription)") // Print error if saving fails
        }

        return product // Return the created product object
    }

    // Storage Picker View - Allows the user to select a storage option
    private var storagePicker: some View {
        VStack(alignment: .leading) {
            Text("Select Storage:")
                .font(.headline)
                .padding(.bottom, 5) // Add padding below the title
            Picker("Storage", selection: $selectedStorage) {
                ForEach(model.storage, id: \.self) { storage in
                    Text(storage) // Display each storage option
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // Use segmented style for the storage picker
            .padding(.bottom, 10) // Add padding at the bottom
        }
    }

    // Color Picker View - Allows the user to select a color option
    private var colorPicker: some View {
        VStack(alignment: .leading) {
            Text("Select Color:")
                .font(.headline)
            
            Picker("Color", selection: $selectedColor) {
                ForEach(model.colors, id: \.self) { color in
                    Text(color) // Display each color option
                }
            }
            .pickerStyle(WheelPickerStyle()) // Use wheel style for the color picker
        }
    }

    // Carrier Picker View - Allows the user to select a carrier option
    private var carrierPicker: some View {
        VStack(alignment: .leading) {
            Text("Select Carrier:")
                .font(.headline)
                .padding(.bottom, 5) // Add padding below the title
            Picker("Carrier", selection: $selectedCarrier) {
                Text("Bell").tag("Bell")
                Text("Rogers").tag("Rogers")
                Text("Telus").tag("Telus")
            }
            .pickerStyle(SegmentedPickerStyle()) // Use segmented style for the carrier picker
            .padding(.bottom, 10) // Add padding at the bottom
        }
    }

    // Checkout Button - A button to navigate to the checkout screen with the selected product
    private var checkoutButton: some View {
        NavigationLink(destination: CheckoutScreen(product: createProduct())) {
            Text("Proceed to Checkout")
                .font(.headline)
                .foregroundColor(.white) // White text for the button
                .padding() // Add padding inside the button
                .background(Color.blue) // Blue background for the button
                .cornerRadius(10) // Rounded corners for the button
        }
        .padding(.top, 10) // Add padding at the top of the button
    }
}

