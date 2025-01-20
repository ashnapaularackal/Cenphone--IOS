//
//  PaymentScreen.swift
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

// Enum for defining different payment methods, making it easier to handle different cases
struct PaymentScreen: View {
    
    enum PaymentMethod: String, CaseIterable, Identifiable {
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case applePay = "Apple Pay"
        case googlePay = "Google Pay"
        
        var id: String { self.rawValue }
    }
    
    // State variables for payment method selection, form fields, errors, and navigation
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    @State private var cardNumber: String = "" // Card number input field
    @State private var expiryDate: String = "" // Expiry date input field
    @State private var cvv: String = "" // CVV input field
    @State private var cardHolderName: String = "" // Cardholder's name input field
    
    // Error messages for validation of input fields
    @State private var cardNumberError: String? = nil
    @State private var expiryDateError: String? = nil
    @State private var cvvError: String? = nil
    @State private var cardHolderNameError: String? = nil
    
    // Navigation state to move to the confirmation screen once payment is confirmed
    @State private var navigateToConfirmation = false
    @State private var orderDetails: OrderDetails?
    
    // Product and user information passed from previous screens
    var model: String
    var price: String
    var storage: String
    var color: String
    var customerName: String
    var deliveryAddress: String
    var productId: UUID // Unique identifier for the product being purchased

    var body: some View {
        // ScrollView to allow scrolling on smaller screens
        ScrollView {
            VStack(spacing: 24) {
                // Payment Information Title
                Text("Payment Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                // Picker to allow the user to select the payment method
                Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                    ForEach(PaymentMethod.allCases) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Display picker as segmented control
                .padding()
                
                // Payment fields for Credit/Debit cards
                if selectedPaymentMethod == .creditCard || selectedPaymentMethod == .debitCard {
                    paymentFieldsSection
                }
                
                // Navigation link to go to the confirmation screen when payment is confirmed
                NavigationLink(destination: ConfirmationScreen(orderDetails: orderDetails ?? createOrderDetails()), isActive: $navigateToConfirmation) {
                    confirmPaymentButton
                }
                
                Spacer()
            }
            .padding(.horizontal, 20) // Horizontal padding for the whole screen
            .padding(.bottom, 40) // Bottom padding for better spacing
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)) // Gradient background
            .edgesIgnoringSafeArea(.all) // Make the background fill the screen
            .navigationTitle("Payment") // Set the title for the navigation bar
            .navigationBarTitleDisplayMode(.inline) // Display title inline with the navigation bar
        }
    }
    
    // View that contains the form fields for card details
    private var paymentFieldsSection: some View {
        VStack(alignment: .leading) {
            // Cardholder name field
            CardDetailTextField(placeholder: "Cardholder Name", text: $cardHolderName, iconName: "person.fill")
                .onChange(of: cardHolderName) { _ in validateCardHolderName() }
            errorMessage(for: cardHolderNameError) // Show error message if any
            
            // Card number field
            CardDetailTextField(placeholder: "Card Number", text: $cardNumber, iconName: "creditcard.fill")
                .keyboardType(.numberPad)
                .onChange(of: cardNumber) { _ in validateCardNumber() }
            errorMessage(for: cardNumberError) // Show error message if any
            
            // Expiry date field
            CardDetailTextField(placeholder: "MM/YY", text: $expiryDate, iconName: "calendar")
                .keyboardType(.numberPad)
                .onChange(of: expiryDate) { newValue in
                    expiryDate = formatExpiryDate(newValue)
                    validateExpiryDate()
                }
            errorMessage(for: expiryDateError) // Show error message if any

            // CVV field
            CardDetailTextField(placeholder: "CVV", text: $cvv, iconName: "lock.fill")
                .keyboardType(.numberPad)
                .onChange(of: cvv) { _ in validateCVV() }
            errorMessage(for: cvvError) // Show error message if any
        }
    }

    // Function to return an error message view if there is an error
    private func errorMessage(for errorMessage: String?) -> some View {
        if let error = errorMessage {
            return AnyView(Text(error).foregroundColor(.red).font(.caption)) // Display error in red
        } else {
            return AnyView(EmptyView()) // No error, show empty view
        }
    }

    // Confirm Payment button
    private var confirmPaymentButton: some View {
        Text("Confirm Payment")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isFormValid() ? Color.blue : Color.gray) // Enable button only when form is valid
            .cornerRadius(10)
            .disabled(!isFormValid()) // Disable button if form is not valid
    }

    // Create an OrderDetails object with the current data
    private func createOrderDetails() -> OrderDetails {
        return OrderDetails(
            brand: "Apple", // Hardcoded brand (can be dynamic based on the product)
            model: model,
            price: price,
            storage: storage,
            color: color,
            customerName: customerName,
            deliveryAddress: deliveryAddress,
            productId: productId // Pass productId here
        )
    }

    // Trigger order confirmation and navigate to the confirmation screen
    private func confirmPayment() {
        if isFormValid() {
            orderDetails = createOrderDetails() // Create order details
            navigateToConfirmation = true // Trigger navigation to confirmation screen
        }
    }

    // Check if the form is valid based on the selected payment method and input validation
    private func isFormValid() -> Bool {
        switch selectedPaymentMethod {
        case .creditCard, .debitCard:
            return cardHolderNameError == nil && cardNumberError == nil && expiryDateError == nil && cvvError == nil && !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardHolderName.isEmpty
        case .applePay, .googlePay:
            return true // These payment methods don't require input fields, so they're always valid
        }
    }

    // Validate the card number to ensure it is 16 digits
    private func validateCardNumber() {
        let cleaned = cardNumber.filter { $0.isNumber }
        if cleaned.count != 16 {
            cardNumberError = "Card number must be 16 digits"
        } else {
            cardNumberError = nil
        }
    }

    // Validate the expiry date in MM/YY format
    private func validateExpiryDate() {
        let components = expiryDate.split(separator: "/")
        guard components.count == 2, let month = Int(components[0]), let year = Int(components[1]) else {
            expiryDateError = "Enter a valid date (MM/YY)"
            return
        }
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if year < currentYear || year > currentYear + 10 {
            expiryDateError = "Invalid year"
        } else if year == currentYear && month < currentMonth {
            expiryDateError = "Card has expired"
        } else if month < 1 || month > 12 {
            expiryDateError = "Invalid month"
        } else {
            expiryDateError = nil
        }
    }

    // Validate the CVV number (3 or 4 digits)
    private func validateCVV() {
        let cleaned = cvv.filter { $0.isNumber }
        if cleaned.count != 3 && cleaned.count != 4 {
            cvvError = "CVV must be 3 or 4 digits"
        } else {
            cvvError = nil
        }
    }

    // Validate the cardholder's name
    private func validateCardHolderName() {
        if cardHolderName.isEmpty {
            cardHolderNameError = "Cardholder name is required"
        } else {
            cardHolderNameError = nil
        }
    }

    // Format expiry date input to MM/YY format
    private func formatExpiryDate(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        
        if cleaned.count > 4 { return String(cleaned.prefix(4)) }
        
        if cleaned.count > 2 {
            return cleaned.prefix(2) + "/" + cleaned.dropFirst(2)
        }
        
        return cleaned
    }
}

// Custom text field component for card details with an icon and validation
struct CardDetailTextField: View {
    var placeholder: String
    @Binding var text: String
    var iconName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconName) // Display an icon inside the text field
                    .foregroundColor(.gray)
                TextField(placeholder, text: $text) // Text field for user input
                    .padding()
                    .background(Color.white.opacity(0.8)) // Background with some transparency
                    .cornerRadius(12)
                    .shadow(radius: 5) // Slight shadow for a 3D effect
            }
            .padding(.horizontal) // Horizontal padding for the text field
            .frame(height: 50) // Set a fixed height for the text field
        }
        .padding(.vertical, 5) // Vertical padding between fields
    }
}

// Preview for Payment Screen
struct PaymentScreen_Previews: PreviewProvider {
    static var previews: some View {
        PaymentScreen(
            model: "iPhone 13 Pro",
            price: "$999",
            storage: "256GB",
            color: "Sierra Blue",
            customerName:"John Doe",
            deliveryAddress:"123 Main St, Anytown, AN 12345",
            productId: UUID() // Provide a sample UUID for previewing purposes
        )
    }
}

