//
//  BrandSelectionScreen.swift
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
//  This screen allows users to select a brand from a list of available smartphone brands,
//  which includes iPhone, Samsung, and Google Pixel. Each brand is displayed with its logo
//  and navigates to the model selection screen.
//

import SwiftUI

struct BrandSelectionScreen: View {
    let brands = ["iPhone", "Samsung", "Google Pixel"]
    let brandLogos = [
        "iPhone": "iPhoneLogo",
        "Samsung": "SamsungLogo",
        "Google Pixel": "GoogleLogo"
    ]

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Covers entire screen with gradient

            VStack {
                // Screen Title
                Text("Shop by Brands")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                // List of Brands
                List(brands, id: \.self) { brand in
                    NavigationLink(destination: ModelSelectionScreen(brand: brand)) {
                        HStack {
                            // Brand Logo
                            if let logoName = brandLogos[brand] {
                                Image(logoName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50) // Logo size
                                    .padding(.trailing, 15) // Space between logo and text
                            }
                            // Brand Name
                            Text(brand)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white) // Background for each list item
                        .cornerRadius(12) // Rounded corners for the item
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Shadow effect
                    }
                    .padding(.vertical, 8) // Vertical spacing between items
                }
                .listStyle(PlainListStyle())
                .padding(.top, 10) // Padding for the top of the list
            }
        }
        
        .navigationBarBackButtonHidden(false)
      
    }
}

struct BrandSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrandSelectionScreen()
        }
    }
}
