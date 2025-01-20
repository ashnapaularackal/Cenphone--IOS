//  LoginView.swift

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

// CustomerLogin: Login screen for the user to enter their credentials
struct CustomerLogin: View {
    // Core Data context for accessing data
    @Environment(\.managedObjectContext) private var viewContext
    
    // State variables to manage form inputs and UI elements
    @State private var email = "" // Email entered by the user
    @State private var password = "" // Password entered by the user
    @State private var loginMessage = "" // Message displayed after login attempt (success or failure)
    @State private var isLoggedIn = false // Flag to track if the user is successfully logged in
    @State private var isPasswordVisible = false // Flag to toggle visibility of password input field
    @State private var navigateToProfile = false // Flag to control navigation to the profile screen

    // Instance of ReadData for authenticating the user
    let isAuthenticated = ReadData()

    var body: some View {
        // Main container using NavigationView for managing navigation between views
        NavigationView {
            ZStack {
                // Background gradient for the login screen
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea() // Ensure the gradient covers the entire screen

                // ScrollView to allow scrolling when the keyboard is shown
                ScrollView {
                    VStack(spacing: 30) {
                        // Welcome Message
                        Text("Welcome Back!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 5) // Adding a shadow for better visibility

                        // Subheading to guide the user
                        Text("Please log in to continue")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)

                        // Form container for email and password fields
                        VStack(spacing: 15) {
                            // Email Input Field
                            HStack {
                                // Icon for email
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                
                                // TextField for email input
                                TextField("Enter your Email", text: $email)
                                    .autocapitalization(.none) // Disable auto-capitalization for email
                                    .disableAutocorrection(true) // Disable autocorrection for email
                            }
                            .padding() // Padding around the text field
                            .background(Color.white.opacity(0.9)) // Light background color for the text field
                            .cornerRadius(12) // Rounded corners for the field
                            .shadow(radius: 3) // Shadow for the field for better visibility

                            // Password Input Field
                            HStack {
                                // Icon for password field
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                
                                // Conditionally display a TextField or SecureField based on the visibility flag
                                if isPasswordVisible {
                                    TextField("Enter your Password", text: $password)
                                } else {
                                    SecureField("Enter your Password", text: $password)
                                }
                                
                                // Eye icon to toggle password visibility
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .onTapGesture {
                                        isPasswordVisible.toggle() // Toggle password visibility on tap
                                    }
                                    .foregroundColor(Color.gray) // Gray color for the icon
                            }
                            .padding() // Padding for the password field
                            .background(Color.white.opacity(0.9)) // Background color for the field
                            .cornerRadius(12) // Rounded corners for the password field
                            .shadow(radius: 3) // Shadow for the field
                        }
                        .padding() // Padding around the form container
                        .background(Color.white.opacity(0.9)) // White background with some opacity
                        .cornerRadius(15) // Rounded corners for the form container
                        .shadow(radius: 5) // Shadow for the form container

                        // Submit Button
                        Button(action: login) {
                            // Button text
                            Text("Submit")
                                .frame(maxWidth: .infinity) // Make the button expand to full width
                                .padding() // Padding inside the button
                                .foregroundColor(.white) // White text color
                                .background(Color.green) // Green background for the button
                                .cornerRadius(8) // Rounded corners for the button
                                .shadow(radius: 3) // Shadow effect on the button
                        }

                        // Login Message (success or failure)
                        if !loginMessage.isEmpty {
                            Text(loginMessage) // Display the login message
                                .font(.headline) // Large font for the message
                                .foregroundColor(isLoggedIn ? Color.green : Color.red) // Green for success, red for failure
                                .transition(.opacity) // Fade in/out the message
                        }

                        // Navigation Links for registration and profile pages
                        VStack(spacing: 10) {
                            // Link to Registration View
                            NavigationLink(destination: Registration().navigationBarBackButtonHidden(true)) {
                                Text("Don't have an account? Register Now")
                                    .fontWeight(.medium) // Medium font weight for the link text
                                    .foregroundColor(.white) // White color for the link text
                                    .underline() // Underline the link text
                            }

                            // Navigation Link for Profile (this is triggered once the user is logged in)
                            NavigationLink(destination: ProfileView().navigationBarBackButtonHidden(true), isActive: $navigateToProfile) {
                                EmptyView() // Empty view that gets activated when navigateToProfile becomes true
                            }
                        }
                    }
                    .padding() // Padding for the entire content inside the ScrollView
                }
            }
        }
    }

    // Login function to authenticate the user
    private func login() {
        // Use ReadData's authenticator function to verify the email and password
        let loggedIn = isAuthenticated.authenticator(email: email, password: password, viewContext: viewContext)
        
        // If login is successful
        if loggedIn {
            // Store the logged-in user's email in UserDefaults
            UserDefaults.standard.set(email, forKey: "loggedInUserEmail")
            
            // Set login message and success flag
            loginMessage = "Login Successful"
            isLoggedIn = true
            
            // Set navigateToProfile flag to true to trigger navigation to Profile view
            navigateToProfile = true
        } else {
            // If login fails, set the error message and update the failure flag
            loginMessage = "Invalid email or password"
            isLoggedIn = false
        }
    }
}

