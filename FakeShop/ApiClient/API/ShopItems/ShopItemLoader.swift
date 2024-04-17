//
//  ShopItemLoader.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 08/04/2024.
//

import Foundation

public enum LoadShopItemsResult {
    case success([ShopItem])
    case failure(Error)
}

public protocol ShopItemLoader {
    
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadShopItemsResult) -> Void) // It's good to have generic errors
}
