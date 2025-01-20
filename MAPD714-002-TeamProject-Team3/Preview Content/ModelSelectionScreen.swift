
//
//  ModelSelectionScreen.swift
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
//  Description:
//  This screen allows users to view and select different models of a specific brand.
//  Each model is displayed with its name, price, image
//  Users can navigate to the checkout screen for a selected model.


import SwiftUI

struct ModelSelectionScreen: View {
    var brand: String // Selected brand passed from the previous screen

    // Sample data for phone models, organized by brand
    let models: [String: [(name: String, price: String, imageName: String, storage: [String], colors: [String])]] = [
        "iPhone": [
            (name: "iPhone 15", price: "$899", imageName: "iPhone15", storage: ["128 GB", "256 GB","512 GB"], colors: ["Red", "Gold","Silver"]),
            (name: "iPhone 15 Pro", price: "$999", imageName: "iPhone15Pro", storage: ["128 GB", "256 GB", "512 GB"], colors: ["Graphite", "Silver","Blue"]),
            (name: "iPhone 14", price: "$799", imageName: "iPhone14", storage: ["64 GB", "128 GB", "256 GB"], colors: ["Blue", "Black", "Silver"]),
            (name: "iPhone 13", price: "$799", imageName: "iPhone13", storage: ["64 GB", "128 GB", "256 GB"], colors: ["Blue", "Black", "Silver"]),
            
        ],
        "Samsung": [
            (name: "Galaxy S23", price: "$699", imageName: "GalaxyS23", storage: ["128 GB", "256 GB","512 GB"], colors: ["Black", "White", "Silver"]),
            (name: "Galaxy Z Fold 5", price: "$1799", imageName: "GalaxyZFold5", storage: ["256 GB", "512 GB", "128 GB "], colors: ["Phantom Black", "Cream","Silver"]),
            (name: "Galaxy Z Fold 6", price: "$1999", imageName: "GalaxyZFold6", storage: ["128 GB","256 GB", "512 GB"], colors: ["Gray", "Green" ,"Silver"]),
            (name: "Galaxy S21 ", price: "$1999", imageName: "GalaxyS21", storage: ["128 GB","256 GB", "512 GB"], colors: ["Gray", "Green" ,"Silver"]),        ],
        "Google Pixel": [
            (name: "Google Pixel 9", price: "$699", imageName: "GooglePixel9", storage: ["128 GB", "256 GB","64 GB"], colors: ["Obsidian", "Snow", "Blue"]),
            (name: "Google Pixel 9 Pro", price: "$999", imageName: "GooglePixel9Pro", storage: ["128 GB", "256 GB","512 GB"], colors: ["Lemongrass", "Charcoal","Silver"]),
            (name: "Google Pixel 8", price: "$599", imageName: "GooglePixel8", storage: ["128 GB", "256 GB","512 GB"], colors: ["Mint", "Black","Silver"]),
            (name: "Google Pixel 8 Pro", price: "$599", imageName: "GooglePixel8Pro", storage: ["128 GB", "256 GB","512 GB"], colors: ["Mint", "Black","Silver"]),        ]
    ]
    
    // Brand logos dictionary
    let brandLogos = [
        "iPhone": "iPhoneLogo",
        "Samsung": "SamsungLogo",
        "Google Pixel": "GoogleLogo"
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background gradient based on brand
            LinearGradient(gradient: Gradient(colors: brandBackgroundColors(brand: brand)), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Covers the entire screen
            
            VStack {
                // Display the brand logo at the top
                if let logoName = brandLogos[brand] {
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 50)
                        .padding(.top, 20)
                }
                
                // Display title for selected brand models
                Text("Shop By\(brand) Models")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // List of models for the selected brand
                List(models[brand] ?? [], id: \.name) { model in
                    NavigationLink(destination: ModelDetailView(model: model)) {
                        HStack {
                            // Display model image
                            Image(model.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                            
                            // Display model information (name and price)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(model.name)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(model.price)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white) // Background color for each list item
                        .cornerRadius(15) // Rounded corners for the item
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Shadow for elevation
                    }
                    .padding(.vertical, 6) // Space between list items
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 10)
            }
        }
        
        .navigationBarTitleDisplayMode(.inline) // Inline title style for navigation bar
    }
    
    // Function to return background gradient colors based on brand
    func brandBackgroundColors(brand: String) -> [Color] {
        switch brand {
        case "iPhone":
            return [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]
        case "Samsung":
            return [Color.gray.opacity(0.8), Color.black.opacity(0.8)]
        case "Google Pixel":
            return [Color.green.opacity(0.8), Color.blue.opacity(0.8)]
        default:
            return [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]
        }
    }
}
