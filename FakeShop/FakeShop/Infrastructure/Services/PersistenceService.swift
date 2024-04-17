//
//  PersistenceService.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

protocol PersistenceService {
    func retrieve(completion: @escaping (Result<[CachedShopItem], Error>) -> Void)
    func insert(shopItems: [LocalShopItem])
}
