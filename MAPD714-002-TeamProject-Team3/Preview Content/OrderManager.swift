//  OrderManager.swift

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

import CoreData

class OrderManager {
    static let shared = OrderManager()
    
    private init() {}

    // Creates a new order and saves it to Core Data.
    func createOrder(userId: UUID, productId: UUID, totalAmount: Double, status: String, context: NSManagedObjectContext) -> Order? {
        guard let user = fetchUser(with: userId, context: context),
              let product = fetchProduct(with: productId, context: context) else {
            print("Failed to fetch user or product")
            return nil
        }
        
        let order = Order(context: context)
        order.orderId = UUID()
        order.orderDate = Date() // Set the current date as the order date
        order.totalAmount = totalAmount
        order.status = status
        order.user = user
        order.product = product
        
        do {
            try context.save()
            return order
        } catch {
            print("Failed to create order: \(error.localizedDescription)")
            context.rollback()
            return nil
        }
    }
    
    //Fetches all orders from Core Data.
    func fetchOrders(context: NSManagedObjectContext) -> [Order] {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch orders: \(error.localizedDescription)")
            return []
        }
    }
    
    // Fetches all orders for a specific user.
    func fetchOrdersForUser(userId: UUID, context: NSManagedObjectContext) -> [Order] {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        
        // Assuming 'user' relationship exists in Order entity.
        fetchRequest.predicate = NSPredicate(format: "user.customerId == %@", userId as CVarArg)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch orders for user: \(error.localizedDescription)")
            return []
        }
    }
    
    // Updates an existing order's total amount and status.
    func updateOrder(_ order: Order, totalAmount: Double, status: String, context: NSManagedObjectContext) -> Bool {
       order.totalAmount = totalAmount
       order.status = status
        
       do {
           try context.save()
           return true
       } catch {
           print("Failed to update order: \(error.localizedDescription)")
           context.rollback()
           return false
       }
   }

   // Deletes an existing order from Core Data.
   func deleteOrder(_ order: Order, context: NSManagedObjectContext) -> Bool {
       context.delete(order)

       do {
           try context.save()
           return true
       } catch {
           print("Failed to delete order: \(error.localizedDescription)")
           context.rollback()
           return false
       }
   }

   // Fetches a user by their ID from Core Data.
   private func fetchUser(with id: UUID, context: NSManagedObjectContext) -> User? {
       let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
       fetchRequest.predicate = NSPredicate(format: "customerId == %@", id as CVarArg)

       do {
           let users = try context.fetch(fetchRequest)
           return users.first
       } catch {
           print("Failed to fetch user: \(error.localizedDescription)")
           return nil
       }
   }

   // Fetches a product by its ID from Core Data.
   private func fetchProduct(with id: UUID, context: NSManagedObjectContext) -> Product? {
       let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
       fetchRequest.predicate = NSPredicate(format: "productId == %@", id as CVarArg)

       do {
           let products = try context.fetch(fetchRequest)
           return products.first
       } catch {
           print("Failed to fetch product: \(error.localizedDescription)")
           return nil
       }
   }

   //Cancels an existing order if it is less than 24 hours old.
   func cancelOrder(_ order: Order, context: NSManagedObjectContext) -> Bool {
       guard let creationDate = order.orderDate else {
           print("Order date is missing.")
           return false
       }
       
       // Check if the order is less than 24 hours old (86400 seconds in a day).
       if Date().timeIntervalSince(creationDate) < 86400 {
           // Update the status to "Canceled"
           let success = updateOrder(order, totalAmount: order.totalAmount, status: "Canceled", context: context)
           if success {
               print("Order canceled successfully.")
           } else {
               print("Failed to update order status to canceled.")
           }
           return success
       } else {
           print("Cannot cancel an order older than 24 hours.")
           return false
       }
   }
}
