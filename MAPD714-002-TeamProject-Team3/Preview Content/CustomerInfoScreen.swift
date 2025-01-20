
//
//  ContentView.swift
//  MAPD714-002_TeamProject_Team3
//
//  CenPhone Mobile Shopping App
//  Created by Team 3
//  - Ashna Paul (301479554)
//  - Aditya Janjanam (301357523)
//
//  Date: November 4, 2024
//  Version: 1.0

import SwiftUI
import CoreData

// Struct to hold customer information (name, address, phone, email, etc.)
struct CustomerInfo {
    var fullName: String
    var streetAddress: String
    var city: String
    var province: String
    var country: String
    var phoneNumber: String
    var emailAddress: String
}

// CustomerInfoScreen displays and manages the user's information (address, contact details)
struct CustomerInfoScreen: View {
    
    // The managed object context for Core Data operations
    @Environment(\.managedObjectContext) private var viewContext
    
    // State variables to store the customer information and manage UI states
    @State private var customerInfo = CustomerInfo(fullName: "", streetAddress: "", city: "", province: "", country: "", phoneNumber: "", emailAddress: "")
    @State private var isEditingAddress = false // Boolean to track if the user is editing the address
    @State private var isTermsAccepted = false // Boolean to track if terms and conditions are accepted
    @State private var showErrorAlert = false // Flag to show error alerts
    @State private var errorMessage = "" // Message to display in case of an error

    // Variables passed into the screen for the product details
    var model: String
    var price: String
    var storage: String
    var color: String
    var productId: UUID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Screen title
                Text("Customer Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                // Display customer information
                Group {
                    // Display each customer information as a non-editable row
                    customerInfoRow(title: "Full Name:", value: customerInfo.fullName)

                    // Address fields that can be edited
                    editableInfoRow(title: "Street Address:", value: $customerInfo.streetAddress, isEditing: $isEditingAddress)
                    editableInfoRow(title: "City:", value: $customerInfo.city, isEditing: $isEditingAddress)
                    editableInfoRow(title: "Province:", value: $customerInfo.province, isEditing: $isEditingAddress)
                    editableInfoRow(title: "Country:", value: $customerInfo.country, isEditing: $isEditingAddress)

                    // Display phone number and email as non-editable rows
                    customerInfoRow(title: "Phone Number:", value: customerInfo.phoneNumber)
                    customerInfoRow(title: "Email Address:", value: customerInfo.emailAddress)

                    // Button to toggle between editing and saving address
                    Button(action: {
                        if isEditingAddress {
                            // If editing is finished, save the data
                            saveCustomerInfo()
                        }
                        isEditingAddress.toggle()
                    }) {
                        Text(isEditingAddress ? "Save Changes" : "Edit Delivery Address")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isEditingAddress ? Color.green : Color.blue) // Change button color based on editing state
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                }
                
                // Terms acceptance section
                HStack {
                    // Checkbox for accepting terms and conditions
                    Button(action: { isTermsAccepted.toggle() }) {
                        Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square.fill")
                            .foregroundColor(isTermsAccepted ? Color.blue : Color.gray)
                            .imageScale(.large)
                    }
                    
                    Text("I accept the terms and conditions")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                // Proceed to payment button
                NavigationLink(destination:
                                PaymentScreen(
                                    model: model,
                                    price: price,
                                    storage: storage,
                                    color: color,
                                    customerName: customerInfo.fullName,
                                    deliveryAddress:
                                        "\(customerInfo.streetAddress), \(customerInfo.city), \(customerInfo.province), \(customerInfo.country)",
                                    productId: productId // Pass productId here
                                )) {
                    Text("Proceed to Payment")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isTermsAccepted && isValidAddress() ? Color.blue : Color.gray.opacity(0.5)) // Disable button if terms are not accepted or address is invalid
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isTermsAccepted || !isValidAddress()) // Disable button when conditions are not met

                Spacer()
            }
            .padding() // Padding around the whole screen
            .background(LinearGradient(gradient:
                                        Gradient(colors:
                                                    [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                      startPoint:.top,
                                      endPoint:.bottom)) // Background gradient for the screen
            .edgesIgnoringSafeArea(.all) // Make the background extend to the edges of the screen
        }
        // Fetch customer info when the screen appears
        .onAppear {
            fetchCustomerInfo()
        }
        // Display error alert if there is an error
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    // Helper function to display a customer info row (non-editable)
    private func customerInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }

    // Helper function to display editable customer info row
    private func editableInfoRow(title: String, value: Binding<String>, isEditing: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            if isEditing.wrappedValue {
                // TextField for editable fields (address, city, province, country)
                TextField("Enter \(title)", text: value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            } else {
                // Display non-editable value
                Text(value.wrappedValue)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
    }

    // Function to check if the address is valid (all address fields must be filled)
    private func isValidAddress() -> Bool {
        return !customerInfo.streetAddress.isEmpty &&
               !customerInfo.city.isEmpty &&
               !customerInfo.province.isEmpty &&
               !customerInfo.country.isEmpty
    }

    // Function to fetch the logged-in user's customer information from Core Data
    private func fetchCustomerInfo() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        // Get the logged-in user's email from UserDefaults
        if let email = UserDefaults.standard.string(forKey: "loggedInUserEmail") {
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            do {
                // Fetch user data
                let users = try viewContext.fetch(fetchRequest)
                if let user = users.first {
                    // Populate the customerInfo struct with fetched data
                    customerInfo.fullName = user.fullName ?? ""
                    customerInfo.streetAddress = user.address ?? ""
                    customerInfo.city = user.city ?? ""
                    customerInfo.province = user.province ?? ""
                    customerInfo.country = user.country ?? ""
                    customerInfo.phoneNumber = user.telephone ?? ""
                    customerInfo.emailAddress = user.email ?? ""
                }
            } catch {
                // Show error if fetching fails
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        } else {
            // Show error if no logged-in user is found
            errorMessage = "No logged-in user found."
            showErrorAlert = true
        }
    }

    // Function to save the modified customer info to Core Data
    private func saveCustomerInfo() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        if let email = UserDefaults.standard.string(forKey: "loggedInUserEmail") {
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            do {
                let users = try viewContext.fetch(fetchRequest)
                if let user = users.first {
                    // Update user's address fields with the new information
                    user.address = customerInfo.streetAddress
                    user.city = customerInfo.city
                    user.province = customerInfo.province
                    user.country = customerInfo.country
                    try viewContext.save() // Save changes to Core Data
                    print("Customer info saved successfully.")
                }
            } catch {
                // Show error if saving fails
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

// Preview for the Customer Info Screen
struct CustomerInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerInfoScreen(model: "iPhone 13 Pro",
                          price: "$999",
                          storage: "256GB",
                          color: "Sierra Blue",
                          productId: UUID())
    }
}

