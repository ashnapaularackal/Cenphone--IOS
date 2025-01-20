//
//  ReadData.swift


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

// ProfileView: This view displays a user's profile and allows them to edit their personal information.
struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var user: FetchedResults<User>

    // User profile fields
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
    
    // Edit state and alert messages
    @State private var isEditing = false
    @State private var navigateToBrandSelection = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var shouldLogout = false

    // Country and Province data for the picker
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

    // Initialize the view with a user predicate for fetching the logged-in user
    init() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "loggedInUserEmail") ?? ""
        let predicate = NSPredicate(format: "email == %@", loggedInUserEmail)
        _user = FetchRequest(entity: User.entity(), sortDescriptors: [], predicate: predicate)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background for the entire ProfileView
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                // Form to display and edit profile information
                Form {
                    // Section for profile information
                    Section(header: Text("Profile Information").font(.headline)) {
                        // Profile Fields (Editable and non-editable)
                        profileField(title: "Full Name", value: $fullName, placeholder: "Enter your full name", isEditable: false)
                        profileField(title: "Email", value: $email, placeholder: "Enter your email", isEditable: false)
                        profileField(title: "Username", value: $username, placeholder: "Enter your username", isEditable: false)
                        profileField(title: "Address", value: $address, placeholder: "Enter your address", isEditable: isEditing)
                        profileField(title: "City", value: $city, placeholder: "Enter your city", isEditable: isEditing)

                        // Province/State Picker or TextField (Editable when isEditing is true)
                        if isEditing {
                            VStack(alignment: .leading) {
                                Text("Province/State")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                if let options = countryData[country], !options.isEmpty {
                                    // Use a Picker for predefined province/state options
                                    Picker("Select Province/State", selection: $province) {
                                        ForEach(options, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .onChange(of: province) { newValue in
                                        if !newValue.isEmpty {
                                            alertMessage = ""
                                        }
                                    }
                                } else {
                                    // Allow manual input for province/state if no predefined options
                                    TextField("Enter your province/state", text: $province)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: province) { newValue in
                                            if newValue.isEmpty {
                                                alertMessage = "Province/State is required"
                                            }
                                        }
                                }
                                
                                // Display error message if province/state is empty
                                if province.isEmpty {
                                    Text("Province/State is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            // Non-editable fields for Province/State and Country
                            profileField(title: "Province/State", value: $province, placeholder: "Enter your province/state", isEditable: false)
                            profileField(title: "Country", value: $country, placeholder: "Enter your country", isEditable: false)
                        }

                        // Telephone field (Editable when isEditing is true)
                        profileField(title: "Telephone", value: $telephone, placeholder: "Enter your telephone", isEditable: isEditing)

                        // Password fields (Editable when isEditing is true)
                        if isEditing {
                            SecureField("New Password", text: $password)
                                .textContentType(.newPassword)
                            SecureField("Confirm New Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                        }
                    }

                    // Section with buttons for saving or canceling changes
                    Section {
                        if isEditing {
                            Button(action: updateProfile) {
                                Text("Save Changes")
                                    .foregroundColor(.green)
                            }
                            Button(action: { isEditing.toggle() }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: { isEditing.toggle() }) {
                                Text("Edit Profile")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // Section for navigating to brand selection screen
                    Section {
                        Button(action: {
                            navigateToBrandSelection = true
                        }) {
                            Text("Continue to Brand Selection")
                                .foregroundColor(.purple)
                        }
                    }
                }
                // Navigation and Logout button
                .navigationTitle("Welcome, \(firstName)")
                .onAppear {
                    loadUserData()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(trailing:
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "loggedInUserEmail")
                        shouldLogout = true
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                )
                // Navigation Link for Brand Selection Screen
                .background(
                    NavigationLink(destination: BrandSelectionScreen().navigationBarBackButtonHidden(false), isActive: $navigateToBrandSelection) {
                        EmptyView()
                    }
                )
                // Navigation Link for Logout
                .background(
                    NavigationLink(destination: MainScreen().navigationBarBackButtonHidden(true), isActive: $shouldLogout) {
                        EmptyView()
                    }
                )
                // Displaying Alert for Profile Update Status
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Profile Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .accentColor(.purple)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Helper to extract the first name from the full name
    private var firstName: String {
        fullName.components(separatedBy: " ").first ?? ""
    }

    // Function to display editable/non-editable profile fields
    private func profileField(title: String, value: Binding<String>, placeholder: String, isEditable: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            if isEditable {
                TextField(placeholder, text: value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(value.wrappedValue)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 5)
    }

    // Function to load user data from CoreData
    private func loadUserData() {
        if let user = user.first {
            fullName = user.fullName ?? ""
            address = user.address ?? ""
            city = user.city ?? ""
            country = user.country ?? "Canada"
            province = user.province ?? ""
            telephone = user.telephone ?? ""
            email = user.email ?? ""
            username = user.username ?? ""
        }
    }

    // Function to update user profile in CoreData
    private func updateProfile() {
        if let user = user.first {
            if !password.isEmpty {
                if password != confirmPassword {
                    alertMessage = "Passwords do not match"
                    showingAlert = true
                    return
                }
                user.password = password
            }

            user.address = address
            user.city = city
            user.country = country
            user.province = province
            user.telephone = telephone

            // Save changes to CoreData
            do {
                try viewContext.save()
                alertMessage = "Profile updated successfully!"
                showingAlert = true
                isEditing.toggle()
                password = ""
                confirmPassword = ""
            } catch {
                alertMessage = "Failed to save changes: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

// PickerField: A reusable component for rendering a picker with optional validation
struct PickerField: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    var onChange: (() -> Void)? = nil // Optional callback for handling changes

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Picker(selection: $selection, label: Text(title)) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selection) { _ in
                onChange?()
            }

            if selection.isEmpty {
                Text("\(title) is required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 5)
    }
}

