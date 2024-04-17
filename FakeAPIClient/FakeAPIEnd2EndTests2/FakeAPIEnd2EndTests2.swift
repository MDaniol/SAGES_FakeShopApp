//
//  FakeAPIEnd2EndTests2.swift
//  FakeAPIEnd2EndTests2
//
//  Created by Mateusz Danioł on 17/04/2024.
//

import XCTest
import FakeAPIClient

final class FakeAPIEnd2EndTests2: XCTestCase {
    
    func test_endToEndFakeStoreAPI_matchesFixedTestAccountData() {
        
        let testServerURL = URL(string: "https://fakestoreapi.com/products?limit=2")!
        
        let client = URLSessionHTTPClient(session: .shared)
        
        let loader = RemoteShopItemsLoader(client: client, url: testServerURL)
        
        var receivedResult: RemoteShopItemsLoader.Result?
        
        let exp = expectation(description: "Wait for API to return data")
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        
        switch receivedResult {
        case .success(let shopItems):
            XCTAssertEqual(shopItems[0], shopItem(at: 0))
            XCTAssertEqual(shopItems[1], shopItem(at: 1))
            XCTAssertEqual(shopItems.count, 2)
        default:
            XCTFail("Backend test data inconsistent or missing")
        }
    }
    
    private func shopItem(at index: Int) -> ShopItem {
        return ShopItem(id: id(at: index),
                        title: title(at: index),
                        price: price(at: index),
                        category: category(at: index),
                        description: description(at: index),
                        imageURL: imageUrl(at: index),
                        rating: rating(at: index))
    }
    
    private func rating(at index: Int) -> Rating {
        return Rating(rate: userRate(at: index), userCount: userCount(at: index))
    }
    
    private func id(at index: Int) -> Int {
        return [1, 2][index]
    }
    
    private func price(at index: Int) -> Double {
        return [109.95, 22.3][index]
    }
    
    func userRate(at index: Int) -> Double {
        return [3.9, 4.1][index]
    }
    
    func userCount(at index: Int) -> Int {
        return [120, 259][index]
    }
    
    func title(at index: Int) -> String {
        return [
            "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
            "Mens Casual Premium Slim Fit T-Shirts "
            ][index]
    }
    
    private func description(at index: Int) -> String {
        return [
            "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
            "Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing. And Solid stitched shirts with round neck made for durability and a great fit for casual fashion wear and diehard baseball fans. The Henley style round neckline includes a three-button placket."
        ][index]
    }
    
    private func category(at index: Int) -> String {
        return [
            "men\'s clothing",
            "men\'s clothing"
        ][index]
    }
    
    private func imageUrl(at index: Int) -> String {
        return [
            "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
            "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg"
        ][index]
    }
}
