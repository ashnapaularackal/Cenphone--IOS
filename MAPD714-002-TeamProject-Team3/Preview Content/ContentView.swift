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
//
//  Description:
//  This is the main screen of the CenPhone mobile shopping application,
//  providing users with an easy way to browse and order smartphones online.
//  The screen includes a background image, an app logo, a description of the app,
//  and navigation buttons to start shopping by either logging in or registering.
//

import SwiftUI

// MainScreen is the first screen the user will see after launching the app
struct MainScreen: View {
    var body: some View {
        // NavigationView allows us to have navigation within the app
        NavigationView {
            ZStack {
                // Background Image Setup
                Image("BackgroundImage") // The background image is set here, make sure you have this image in your assets
                    .resizable() // Allows the image to resize based on screen size
                    .scaledToFill() // Ensures the image fills the screen
                    .edgesIgnoringSafeArea(.all) // Ignore safe area to make sure image covers the entire screen
                    .overlay(Color.black.opacity(0.5)) // Add a semi-transparent overlay to darken the image slightly for better readability
                
                // VStack is used to stack the UI elements vertically
                VStack {
                    Spacer() // Pushes the content down towards the center of the screen
                    
                    // App Title: CenPhone
                    Text("CenPhone")
                        .font(.title) // Large title font
                        .multilineTextAlignment(.center) // Center the text
                        .padding() // Add padding around the text
                        .foregroundColor(.white) // White color for the text to contrast with the background
                    
                    // App Logo
                    Image("CenPhoneLogo") // Logo image placed here, ensure the image is available in assets
                        .resizable() // Resize the image to fit in the frame
                        .scaledToFit() // Keep the aspect ratio of the image
                        .frame(width: 100, height: 100) // Set the size of the image
                        .padding() // Add padding around the logo

                    // App Description
                    Text("Order your favorite smartphones \n online with ease.")
                        .font(.title2) // Slightly smaller than the app title
                        .multilineTextAlignment(.center) // Center the text
                        .padding() // Padding for spacing
                        .foregroundColor(.white) // White color for the text

                    // Buttons for User Interaction: Log In and Register
                    VStack(spacing: 15) {
                        // Log In Button - NavigationLink to the CustomerLogin view
                        NavigationLink(destination: CustomerLogin().navigationBarBackButtonHidden(true)) {
                            Text("Log In") // Text for the button
                                .font(.headline) // Headline font for prominence
                                .foregroundColor(.white) // White text color
                                .padding() // Padding for spacing inside the button
                                .frame(maxWidth: .infinity) // Make the button take the full width
                                .background(Color.blue.opacity(0.7)) // Blue background with some transparency
                                .cornerRadius(10) // Rounded corners for the button
                        }

                        // Register Button - NavigationLink to the Registration view
                        NavigationLink(destination: Registration().navigationBarBackButtonHidden(true)) {
                            Text("Register") // Text for the button
                                .font(.headline) // Same headline font for consistency
                                .foregroundColor(.white) // White text color
                                .padding() // Padding for spacing inside the button
                                .frame(maxWidth: .infinity) // Full-width button
                                .background(Color.green.opacity(0.7)) // Green background with some transparency
                                .cornerRadius(10) // Rounded corners for the button
                        }
                    }
                    .padding() // Add padding around the VStack containing the buttons

                    Spacer() // Pushes the button stack up towards the center of the screen
                }
            }
            // Set the navigation bar title display mode
            .navigationBarTitleDisplayMode(.inline) // Title will be displayed in the center, inline with the navigation bar
        }
    }
}

