//
//  ShopItemRepository.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 13/04/2024.
//

import Foundation
import CoreData
import FakeAPIClient

protocol ShopItemRepository {
    func getAllShopItems(callback: @escaping (Result<[LocalShopItem], any Error>) -> Void)
    
    func getLocalItems() async throws -> [LocalShopItem]
    func getRemoteItems() async throws -> [LocalShopItem]
}

class DefaultShopItemRepository: ShopItemRepository {
    private let persistenceService: PersistenceService
    private let remoteItemLoader: RemoteShopItemsLoader = RemoteShopItemsLoader(client: URLSessionHTTPClient(), url: AppDefaults.API.products)
    
    enum ItemRepositoryError: Error {
        case networkError
        case unknownError
    }
    
    init(persistenceService: PersistenceService = CoreDataPersistenceService()) {
        self.persistenceService = persistenceService
    }
    
    func getAllShopItems(callback: @escaping (Result<[LocalShopItem], any Error>) -> Void) {
        
        persistenceService.retrieve { result in
            switch result {
            case .success(let cached):
                callback(.success(cached.map{
                    LocalShopItem.from(cached: $0)
                }))
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        
        remoteItemLoader.load { result in
            switch result {
            case .success(let shopItems):
                let localShopItems = shopItems.map{ shopItem in
                    LocalShopItem.from(domain: shopItem)
                }
                
                self.updateLocalCache(shopItems: localShopItems)
                
                return callback(.success(localShopItems))
            case .failure(let error):
                return callback(.failure(error))
            @unknown default:
                break // TODO: Handle unknown cases
            }
        }
    }
    
    func getLocalItems() async throws -> [LocalShopItem] {
        try await withCheckedThrowingContinuation { continuation in
            persistenceService.retrieve { result in
                switch result {
                case .success(let cachedItems):
                    continuation.resume(returning: cachedItems.map { LocalShopItem.from(cached: $0) })
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getRemoteItems() async throws -> [LocalShopItem] {
        try await withCheckedThrowingContinuation { continuation in
            remoteItemLoader.load { result in
                switch result {
                case .success(let remoteShopItems):
                    continuation.resume(returning: remoteShopItems.map { LocalShopItem.from(domain: $0) })
                case .failure(let error):
                    continuation.resume(throwing: error)
                @unknown default:
                    continuation.resume(throwing: ItemRepositoryError.unknownError)
                }
            }
        }
    }
    
    private func updateLocalCache(shopItems: [LocalShopItem]) {
        persistenceService.insert(shopItems: shopItems)
    }
    
    
}
