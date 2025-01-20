//
//  SharedModels.swift
//  MAPD714-002_TeamProject_Team3
//
// CenPhone Mobile Shopping App
//  Created by Team 3
//  - Ashna Paul (301479554)
//  - Aditya Janjanam (301357523)
//
//  Date: November 3, 2024
//  Version: 1.0//

// SharedModels.swift

import Foundation

struct OrderDetails {
    let brand: String
    let model: String
    let price: String
    let storage: String
    let color: String
    let customerName: String
    let deliveryAddress: String
    let productId: UUID 
}
