//
//  FakeShopAPI.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 02/04/2024.
//

import Foundation

public final class RemoteShopItemsLoader: ShopItemLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadShopItemsResult
    
    let client: FakeShopAPIClient
    let url: URL
    
    public init(client: FakeShopAPIClient,
                url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(ShopItemMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
