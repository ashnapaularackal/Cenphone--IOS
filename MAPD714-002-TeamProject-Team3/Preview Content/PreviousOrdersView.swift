
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

struct PreviousOrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var orders: [Order] = [] // Local array to hold fetched orders
    @State private var filteredOrders: [Order] = [] // Array for filtered results
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true // Loading state
    @State private var showAlert: Bool = false // State for showing alert
    @State private var alertMessage: String = "" // Message for alert

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()

                if isLoading {
                    ProgressView("Loading Orders...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredOrders.isEmpty {
                    Text("No previous orders found.")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(filteredOrders, id: \.self) { order in
                            OrderRow(order: order, onCancel: { cancelOrder(order) })
                                .listRowBackground(Color.clear) // Make list row background clear for gradient effect
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Orders")
            .onAppear(perform: fetchOrdersForUser)
            .onChange(of: searchText) { _ in
                filterOrders()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Order Canceled"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchOrdersForUser() {
        isLoading = true // Start loading
        guard let userIdString = UserDefaults.standard.string(forKey: "loggedInUserId"),
              let userId = UUID(uuidString: userIdString) else {
            errorMessage = "User ID not found."
            isLoading = false // Stop loading
            return
        }

        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user.customerId == %@", userId as CVarArg)

        do {
            orders = try viewContext.fetch(fetchRequest)
            filteredOrders = orders // Initially show all orders
        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
        }
        
        isLoading = false // Stop loading after fetching
    }

    private func filterOrders() {
        if searchText.isEmpty {
            filteredOrders = orders // Show all if search text is empty
        } else {
            filteredOrders = orders.filter { order in
                let orderIDMatches = order.orderId?.uuidString.lowercased().contains(searchText.lowercased()) ?? false
                let productMatches = (order.product?.phoneMake?.lowercased().contains(searchText.lowercased()) ?? false) ||
                                     (order.product?.phoneModel?.lowercased().contains(searchText.lowercased()) ?? false)
                return orderIDMatches || productMatches
            }
        }
    }

    private func cancelOrder(_ order: Order) {
        let result = OrderManager.shared.cancelOrder(order, context: viewContext)
        
        if result {
            alertMessage = "Your order has been successfully canceled."
            showAlert = true
            
            // Refresh orders after cancellation
            fetchOrdersForUser()
        } else {
            alertMessage = "Failed to cancel the order or it is older than 24 hours."
            showAlert = true
        }
    }
}

// OrderRow Component remains unchanged.
struct OrderRow: View {
    let order: Order
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order ID: \(order.orderId?.uuidString.prefix(8) ?? "N/A")")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(order.status ?? "Unknown")
                    .font(.subheadline)
                    .padding(4)
                    .background(statusColor(for: order.status))
                    .cornerRadius(4)
                    .foregroundColor(.white)
            }
            
            Text("Date: \(formattedDate(order.orderDate))")
                .foregroundColor(.white)

            if let product = order.product {
                Text("Product: \(product.phoneMake ?? "") \(product.phoneModel ?? "")")
                    .foregroundColor(.white)
                Text("Color: \(product.phoneColor ?? "")")
                    .foregroundColor(.white)
                Text("Storage: \(product.storageCapacity ?? "")")
                    .foregroundColor(.white)
            }
            
            Text("Total Amount: $\(String(format: "%.2f", order.totalAmount))")
                .font(.headline)
                .foregroundColor(.white)

            // Cancel Button
            Button(action: onCancel) {
                Text("Cancel Order")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(5)
            }
            .disabled(order.status?.lowercased() == "canceled") // Disable if already canceled

        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func statusColor(for status: String?) -> Color {
        switch status?.lowercased() {
        case "confirmed":
            return Color.green.opacity(0.6)
        case "processing":
            return Color.yellow.opacity(0.6)
        case "shipped":
            return Color.blue.opacity(0.6)
        case "delivered":
            return Color.purple.opacity(0.6)
        case "cancelled":
            return Color.red.opacity(0.6)
        default:
            return Color.gray.opacity(0.6)
        }
    }
}

// Search Bar Component remains unchanged.
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search by Order ID or Product Name", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

