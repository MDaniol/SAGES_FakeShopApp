//
//  ShopItemMapper.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 07/04/2024.
//

import Foundation

internal class ShopItemMapper {
    
    static var OK_200: Int { return 200 }
    
    private struct RemoteShopItem: Decodable {
        public let id: Int
        public let title: String
        public let price: Double
        public let category: String
        public let description: String?
        public let image: String
        public let rating: RemoteRating
        
        var shopItem: ShopItem {
            return ShopItem(id: id, title: title, price: price, category: category, description: description, imageURL: image, rating: rating.rating)
        }
        
    }

    private struct RemoteRating: Decodable {
        public let rate: Double
        public let count: Int
        
        var rating: Rating {
            return Rating(rate: rate, userCount: count)
        }
    }
    
    private struct RemoteShopFeed {
        public let remoteShopItems: [RemoteShopItem]
        
        var shopItems: [ShopItem] {
            return remoteShopItems.map { $0.shopItem }
        }
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteShopItemsLoader.Result {
        guard response.statusCode == OK_200,
              let shopItems = try? JSONDecoder().decode([RemoteShopItem].self, from: data) else { return .failure(RemoteShopItemsLoader.Error.invalidData) }
        let shopFeed = RemoteShopFeed(remoteShopItems: shopItems)
        let items = shopFeed.shopItems
        return .success(items)
    }
}
