//
//  InMemoryShopItemStore.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

public class InMemoryShopItemStore {
    private var shopItemCache: [CachedShopItem]?
    
    public init() {}
}

extension InMemoryShopItemStore: ShopItemsStore {
    public func deleteCachedShopItems() throws {
        shopItemCache = nil
    }
    
    public func insert(shopItem: LocalShopItem) {
        shopItemCache?.append(CachedShopItem.from(local: shopItem))
    }
    
    public func retrieve(completion: @escaping (Result<[CachedShopItem], any Error>) -> Void) {
        completion(.success(shopItemCache ?? [] ))
    }
}
