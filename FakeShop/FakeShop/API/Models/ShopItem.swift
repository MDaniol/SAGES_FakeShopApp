//
//  ShopItem.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 02/04/2024.
//

import Foundation

public struct ShopItem: Equatable {
    public let id: Int
    public let title: String
    public let price: Double
    public let category: String
    public let description: String?
    public let imageURL: String
    public let rating: Rating
    
    public init(id: Int, title: String, price: Double, category: String, description: String?, imageURL: String, rating: Rating) {
        self.id = id
        self.title = title
        self.price = price
        self.category = category
        self.description = description
        self.imageURL = imageURL
        self.rating = rating
    }
}

public struct Rating: Equatable {
    
    public init(rate: Double, userCount: Int) {
        self.rate = rate
        self.userCount = userCount
    }
    
    public let rate: Double
    public let userCount: Int
}
