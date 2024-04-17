//
//  ShopItemsListScreenViewModel.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 11/04/2024.
//

import Foundation
import SwiftUI
import FakeAPIClient
import Combine

@MainActor
class ShopItemsListScreenViewModel: ObservableObject {
    @Published var shopItems: [ShopItemsListScreenViewModel.ShopItem] = []
    
    let loadShopItemsUseCase: GetShopItemsUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(loadShopItemsUseCase: GetShopItemsUseCase = GetShopItemsDefaultUseCase(repository: DefaultShopItemRepository())) {
        self.loadShopItemsUseCase = loadShopItemsUseCase
        subscribeToUseCase()
    }
    
    private func subscribeToUseCase() {
        loadShopItemsUseCase.itemsPublisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handle(completion)
                },
                receiveValue: { [weak self] dataState in
                    self?.handle(dataState)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handle(_ dataState:  GetShopItemsDefaultUseCase.ShopItemsDataState) {
        switch dataState {
        case .cached(let items), .remote(let items):
            self.shopItems = self.mapShopItems(items)
        case .loadingCache:
            break // TODO: Handle loading cache UI
        case .loadingRemote:
            break
            // TODO: Handle loading remote UI
        }
    }
    
    private func handle(_ completion: Subscribers.Completion<any Error>) {
        switch completion {
        case .finished:
            // Do nothing
            break
        case .failure(let error):
            debugPrint("Failed to load items: \(error.localizedDescription)")
        }
    }
    
    func loadShopItems() {
        loadShopItemsUseCase.fetchItems()
    }
    
    private func mapShopItems(_ localShopItems: [LocalShopItem]) -> [ShopItemsListScreenViewModel.ShopItem] {
        return localShopItems.map { localShopItem in
            ShopItem(localItem: localShopItem)
        }
    }
}

extension ShopItemsListScreenViewModel {
    enum DataState {
        case cached(LocalShopItem)
        case remote(LocalShopItem)
    }
}

extension ShopItemsListScreenViewModel {
    struct ShopItem: Hashable {
        static func DatasourceMapper(source: LocalShopItem.DataSource) -> ShopItem.DataSource {
            switch source {
            case .cache:
                return .persistence
            case .online:
                return .api
            }
        }
        
        enum DataSource {
            case persistence
            case api
        }
        
        let title: String
        let dataSource: DataSource
        
        init(title: String, datasource: DataSource) {
            self.title = title
            self.dataSource = datasource
        }
        
        init(localItem: LocalShopItem) {
            self.title = localItem.title
            self.dataSource = ShopItemsListScreenViewModel.ShopItem.DatasourceMapper(source: localItem.dataSource)
        }
    }
}


public struct AppDefaults {
    public struct API {
        static private let baseURL: String = "https://fakestoreapi.com"
        static let products: URL = URL(string: baseURL + "/products")!
    }
}




