//
//  GetShopItemsUseCase.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 11/04/2024.
//

import Foundation
import FakeAPIClient
import Combine

protocol GetShopItemsUseCase {
    var itemsPublisher: AnyPublisher<GetShopItemsDefaultUseCase.ShopItemsDataState, Error> { get }
    
    func fetchItems()
    func getCachedItems() async throws -> [LocalShopItem]
    func getRemoteItems() async throws -> [LocalShopItem]
}

class GetShopItemsDefaultUseCase: GetShopItemsUseCase {
    
    private let _itemsSubject = PassthroughSubject<GetShopItemsDefaultUseCase.ShopItemsDataState, Error>()
    var itemsPublisher: AnyPublisher<GetShopItemsDefaultUseCase.ShopItemsDataState, Error> {
        _itemsSubject.eraseToAnyPublisher()
    }
    
    enum ShopItemsDataState {
        case loadingCache
        case cached([LocalShopItem])
        case loadingRemote
        case remote([LocalShopItem])
    }
    
    private let shopItemsRepository: ShopItemRepository
    
    init(repository: ShopItemRepository) {
        self.shopItemsRepository = repository
    }
    
    func fetchItems() {
        Task {
            do {
                let localItems = try await shopItemsRepository.getLocalItems()
                _itemsSubject.send(.cached(localItems))
                
                let remoteItems = try await shopItemsRepository.getRemoteItems()
                _itemsSubject.send(.remote(remoteItems))
            }
        }
    }
    
    func getCachedItems() async throws -> [LocalShopItem] {
        return try await shopItemsRepository.getLocalItems()
    }
    
    func getRemoteItems() async throws -> [LocalShopItem] {
        return try await shopItemsRepository.getRemoteItems()
    }
}
