//
//  FakeShopApp.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 02/04/2024.
//

import SwiftUI
import SwiftData

@main
struct FakeShopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: SDShopItem.self)
    }
}

@Model
class SDShopItem {
    
    let id: Int
    var title: String
    let price: Double
    
    init(id: Int, title: String, price: Double) {
        self.id = id
        self.title = title
        self.price = price
    }
}
