//
//  URLSessionHTTPClient.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 09/04/2024.
//

import Foundation

public class URLSessionHTTPClient: FakeShopAPIClient {
    private let session: URLSession
    
    struct UnexpectedValuesRepresentationError: Error { }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (FakeShopAPIClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(FakeShopAPIClientResult.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(FakeShopAPIClientResult.success(data, response))
            } else {
                completion(FakeShopAPIClientResult.failure(UnexpectedValuesRepresentationError()))
            }
        }.resume() // narazie nie potrzebujemy tu nic
        
    }
}
