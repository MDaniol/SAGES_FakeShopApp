//
//  CoreDataPersistenceService.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

class CoreDataPersistenceService: PersistenceService {
   
    private let shopItemsStore: ShopItemsStore
    
    init(shopItemsStore: ShopItemsStore = PersistenceManager.shared.store) {
        self.shopItemsStore = shopItemsStore
    }
    
    func retrieve(completion: @escaping (Result<[CachedShopItem], any Error>) -> Void) {
        shopItemsStore.retrieve { result in
            switch result {
            case .success(let dbItems):
                completion(.success(dbItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func insert(shopItems: [LocalShopItem]) {
        do {
            try shopItemsStore.deleteCachedShopItems()
            for shopItem in shopItems {
                shopItemsStore.insert(shopItem: shopItem)
            }
        } catch {
            debugPrint(error)
        }
    }
}
