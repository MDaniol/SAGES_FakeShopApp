//
//  LocalShopItem.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 12/04/2024.
//

import Foundation
import FakeAPIClient


public struct CachedShopItem {
    
    let id: Int
    let title: String
    let price: Double
    let category: String
    let description: String?
    let imageURL: String
    let rating: CachedRating
}

extension CachedShopItem {
    static func from(entity: DBShopItem) -> CachedShopItem {
        return CachedShopItem(id: Int(entity.id),
                             title: entity.title ?? "",
                             price: entity.price,
                             category: entity.category ?? "",
                             description: entity.item_description,
                             imageURL:  entity.imageURL ?? "",
                             rating: CachedRating(rate: 0.0, userCount: 0))
    }
}

extension CachedShopItem {
    static func from(local: LocalShopItem) -> CachedShopItem {
        return CachedShopItem(id: local.id,
                              title: local.title,
                              price: local.price,
                              category: local.category,
                              description: local.description,
                              imageURL: local.imageURL,
                              rating: CachedRating.from(local: local.rating))
    }
}

public struct CachedRating {
    let rate: Double
    let userCount: Int
}

extension CachedRating {
    static func from(local: LocalRating) -> CachedRating {
        
        return CachedRating(rate: local.rate,
                            userCount: local.userCount)
    }
}

public struct LocalShopItem: Hashable {
    
    enum DataSource {
        case cache
        case online
    }
    
    let id: Int
    let title: String
    let price: Double
    let category: String
    let description: String?
    let imageURL: String
    let rating: LocalRating
    let dataSource: DataSource
}

public struct LocalRating: Codable, Hashable {
    let rate: Double
    let userCount: Int
}

extension LocalShopItem {
    static func from(domain: ShopItem) -> LocalShopItem {
        return LocalShopItem(
            id: domain.id,
            title: domain.title,
            price: domain.price,
            category: domain.category,
            description: domain.description,
            imageURL: domain.imageURL,
            rating: LocalRating.from(domain: domain.rating),
            dataSource: .online
        )
    }
}

extension LocalShopItem {
    static func from(entity: DBShopItem) -> LocalShopItem {
        return LocalShopItem(id: Int(entity.id),
                             title: entity.title ?? "",
                             price: entity.price,
                             category: entity.category ?? "",
                             description: entity.item_description,
                             imageURL:  entity.imageURL ?? "",
                             rating: LocalRating(rate: 0.0, userCount: 0),
                             dataSource: .cache)
    }
}

extension LocalShopItem {
    static func from(cached: CachedShopItem) -> LocalShopItem {
        return LocalShopItem(id: cached.id,
                             title: cached.title,
                             price: cached.price,
                             category: cached.category,
                             description: cached.description,
                             imageURL:  cached.imageURL,
                             rating: LocalRating(rate: 0.0, userCount: 0),
                             dataSource: .cache)
    }
}

extension ShopItem {
    static func from(locaShopItem: LocalShopItem) -> ShopItem {
        return ShopItem(
            id: locaShopItem.id,
            title: locaShopItem.title,
            price: locaShopItem.price,
            category: locaShopItem.category,
            description: locaShopItem.description,
            imageURL: locaShopItem.imageURL,
            rating: Rating.from(localRating: locaShopItem.rating)
        )
    }
}

extension Rating {
    static func from(localRating: LocalRating) -> Rating {
        return Rating(rate: localRating.rate, userCount: localRating.userCount)
    }
}

extension LocalRating {
    static func from(domain: Rating) -> LocalRating {
        return LocalRating(rate: domain.rate, userCount: domain.userCount)
    }
}
