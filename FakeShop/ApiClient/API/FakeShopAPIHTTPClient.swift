//
//  FakeShopAPIHTTPClient.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 07/04/2024.
//

import Foundation

public enum FakeShopAPIClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol FakeShopAPIClient {
    func get(from url: URL, completion: @escaping (FakeShopAPIClientResult) -> Void )
}

