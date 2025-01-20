//
//  RegisterView.swift
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

// Main Registration View for User Registration
struct Registration: View {
    // Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    
    // Registration form data and state
    @State private var fullName = ""
    @State private var address = ""
    @State private var city = ""
    @State private var province = ""
    @State private var country = "Canada"
    @State private var telephone = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Navigation and validation states
    @State private var navigateToLogin = false
    @State private var registrationMessage = ""
    
    // Validation flags for each field
    @State private var isFullNameValid: Bool = true
    @State private var isAddressValid: Bool = true
    @State private var isCityValid: Bool = true
    @State private var isProvinceValid: Bool = true
    @State private var isCountryValid: Bool = true
    @State private var isTelephoneValid: Bool = true
    @State private var isEmailValid: Bool = true
    @State private var isUsernameValid: Bool = true
    @State private var isPasswordValid: Bool = true
    @State private var isConfirmPasswordValid: Bool = true
    
    // Country and province data for selection
    let countryData = [
        "Canada": ["Ontario", "Quebec", "British Columbia", "Alberta", "Manitoba"],
        "United States": ["California", "Texas", "New York", "Florida", "Illinois"],
        "India": ["Maharashtra", "Tamil Nadu", "Karnataka", "Gujarat", "Punjab"],
        "Australia": ["New South Wales", "Victoria", "Queensland", "Western Australia", "Tasmania"],
        "United Kingdom": ["England", "Scotland", "Wales", "Northern Ireland"]
    ]
    
    let countryCodes = [
        "Canada": "+1",
        "United States": "+1",
        "India": "+91",
        "Australia": "+61",
        "United Kingdom": "+44"
    ]
    
    // Instance of CreateData class to handle user registration
    let createData = CreateData()

    var body: some View {
        // Main container for the registration form
        NavigationView {
            ZStack {
                // Gradient Background for the registration view
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title for the registration form
                        Text("Create an Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(radius: 5)

                        // Form Fields
                        VStack(spacing: 15) {
                            // Full Name Field
                            CustomTextField(
                                placeholder: "Full Name",
                                text: $fullName,
                                isValid: $isFullNameValid,
                                validationMessage: "Full Name is required",
                                validation: { !$0.isEmpty }
                            )

                            // Address Field
                            CustomTextField(
                                placeholder: "Address",
                                text: $address,
                                isValid: $isAddressValid,
                                validationMessage: "Address is required",
                                validation: { !$0.isEmpty }
                            )

                            // City Field
                            CustomTextField(
                                placeholder: "City",
                                text: $city,
                                isValid: $isCityValid,
                                validationMessage: "City is required",
                                validation: { !$0.isEmpty }
                            )
                            
                            // Province Picker
                            VStack(alignment: .leading) {
                                Text("Province/State")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Picker("Select Province/State", selection: $province) {
                                    ForEach(countryData[country] ?? [], id: \.self) { province in
                                        Text(province).tag(province)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .background(province.isEmpty ? Color.red.opacity(0.2) : Color.clear)
                                .onChange(of: province) { newValue in
                                    isProvinceValid = !newValue.isEmpty
                                }
                                if !isProvinceValid {
                                    Text("Province/State is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }

                            // Country Picker
                            VStack(alignment: .leading) {
                                Text("Country")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Picker("Select Country", selection: $country) {
                                    ForEach(countryData.keys.sorted(), id: \.self) { country in
                                        Text(country).tag(country)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: country) { newValue in
                                    isCountryValid = !newValue.isEmpty
                                    province = "" // Reset province on country change
                                    if let code = countryCodes[newValue] {
                                        telephone = replaceCountryCode(in: telephone, with: code)
                                    }
                                }
                                .background(country.isEmpty ? Color.red.opacity(0.2) : Color.clear)
                                if !isCountryValid {
                                    Text("Country is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }

                            // Telephone Field
                            CustomTextField(
                                placeholder: "Telephone",
                                text: $telephone,
                                isValid: $isTelephoneValid,
                                validationMessage: "Enter a valid 10-digit phone number",
                                validation: {
                                    validatePhoneNumberExcludingCountryCode($0)
                                }
                            )

                            // Email Field
                            CustomTextField(
                                placeholder: "Email",
                                text: $email,
                                isValid: $isEmailValid,
                                validationMessage: "Enter a valid email address",
                                validation: { isValidEmail($0) }
                            )

                            // Username Field
                            CustomTextField(
                                placeholder: "Username",
                                text: $username,
                                isValid: $isUsernameValid,
                                validationMessage: "Username must be at least 3 characters",
                                validation: { $0.count >= 3 }
                            )

                            // Password Field
                            SecureCustomTextField(
                                placeholder: "Password",
                                text: $password,
                                isValid: $isPasswordValid,
                                validationMessage: "Password must be at least 6 characters",
                                validation: { $0.count >= 6 }
                            )

                            // Confirm Password Field
                            SecureCustomTextField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isValid: $isConfirmPasswordValid,
                                validationMessage: "Passwords do not match",
                                validation: { $0 == password && !$0.isEmpty }
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 5)

                        // Register Button
                        Button(action: {
                            if validateAllInputs() {
                                let success = createData.registerUser(
                                    fullName: fullName,
                                    address: address,
                                    city: city,
                                    province: province,
                                    country: country,
                                    telephone: telephone,
                                    email: email,
                                    username: username,
                                    password: password,
                                    confirmPassword: confirmPassword,
                                    productDetailsList: nil,
                                    viewContext: viewContext
                                )
                                registrationMessage = success ? "Registration Successful" : "Registration Failed"
                                navigateToLogin = success
                            } else {
                                registrationMessage = "Please correct the highlighted fields."
                            }
                        }) {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .font(.headline)
                        }

                        // Registration Message
                        Text(registrationMessage)
                            .font(.headline)
                            .foregroundColor(navigateToLogin ? Color.green : Color.red)

                        // Navigation to Login Screen
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Already have an account? Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .padding(.top, -30)

                        // Navigation Link to Login
                        NavigationLink(destination: CustomerLogin().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) {
                            EmptyView()
                        }
                    }
                    .padding()
                }
                .onAppear {
                    if let defaultCode = countryCodes[country], telephone.isEmpty {
                        telephone = defaultCode
                    }
                }
            }
        }
    }

    // Helper Function to validate phone numbers excluding country code
    private func validatePhoneNumberExcludingCountryCode(_ phoneNumber: String) -> Bool {
        guard let code = countryCodes[country] else { return false }
        let withoutCode = phoneNumber.replacingOccurrences(of: code, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        return withoutCode.count == 10 && withoutCode.allSatisfy(\.isNumber)
    }

    // Helper function to replace the country code in telephone
    private func replaceCountryCode(in telephone: String, with newCode: String) -> String {
        let regex = "^(\\+\\d+)"
        if let range = telephone.range(of: regex, options: .regularExpression) {
            return telephone.replacingCharacters(in: range, with: newCode)
        }
        return newCode + telephone
    }

    // Function to validate all form inputs
    private func validateAllInputs() -> Bool {
        isFullNameValid = !fullName.isEmpty
        isAddressValid = !address.isEmpty
        isCityValid = !city.isEmpty
        isProvinceValid = !province.isEmpty
        isCountryValid = !country.isEmpty
        isTelephoneValid = validatePhoneNumberExcludingCountryCode(telephone)
        isEmailValid = isValidEmail(email)
        isUsernameValid = username.count >= 3
        isPasswordValid = password.count >= 6
        isConfirmPasswordValid = confirmPassword == password && !confirmPassword.isEmpty

        return isFullNameValid &&
            isAddressValid &&
            isCityValid &&
            isProvinceValid &&
            isCountryValid &&
            isTelephoneValid &&
            isEmailValid &&
            isUsernameValid &&
            isPasswordValid &&
            isConfirmPasswordValid
    }

    // Helper function to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

// Custom TextField with validation
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isValid: Bool
    var validationMessage: String
    var validation: (String) -> Bool

    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(isValid ? Color.clear : Color.red.opacity(0.2))
                .onChange(of: text) { newValue in
                    isValid = validation(newValue)
                }
            if !isValid {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// Custom SecureField with validation
struct SecureCustomTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isValid: Bool
    var validationMessage: String
    var validation: (String) -> Bool

    var body: some View {
        VStack(alignment: .leading) {
            SecureField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(isValid ? Color.clear : Color.red.opacity(0.2))
                .textContentType(.none)
                .autocapitalization(.none)
                .onChange(of: text) { newValue in
                    isValid = validation(newValue)
                }
            if !isValid {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

