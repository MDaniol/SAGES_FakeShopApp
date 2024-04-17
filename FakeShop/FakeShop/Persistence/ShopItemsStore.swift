//
//  ShopItemsStore.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

public protocol ShopItemsStore {
    func deleteCachedShopItems() throws
    func insert(shopItem: LocalShopItem)
    func retrieve(completion: @escaping (Result<[CachedShopItem], Error>) -> Void)
}
