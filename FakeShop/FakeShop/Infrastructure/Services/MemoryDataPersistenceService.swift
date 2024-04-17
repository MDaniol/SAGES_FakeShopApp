//
//  SwiftDataPersistenceService.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

class MemoryDataPersistenceService: PersistenceService {
    func insert(shopItems: [LocalShopItem]) {
        // TODO: Implement in-memory insert method
    }
    
    func retrieve(completion: @escaping (Result<[CachedShopItem], any Error>) -> Void) {
        // TODO: Implement in-memory retrieve method
    }
}
