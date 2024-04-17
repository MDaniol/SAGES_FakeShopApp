//
//  FakeShopTests.swift
//  FakeShopTests
//
//  Created by Mateusz Danioł on 02/04/2024.
//

import XCTest
@testable import FakeAPIClient

final class FakeShopTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://fakestoreapi.com/products")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://fakestoreapi.com/products")!
        let (sut, client) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let dataErrorCodes = [199, 201, 300, 400, 500, 501]
        
        let itemsJson = makeItemsJson([])
        
        dataErrorCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: itemsJson, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("I am invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: 1, title: "Title1", price: 2.0, description: "Desc", category: "Cat1", image: "https://an-image-url.com", rate: 2.0, userCount: 222)
        
        let item2 = makeItem(id: 2, title: "Title2", price: 2.0, description: "Desc", category: "Cat2", image: "https://an-image-url.com", rate: 2.2, userCount: 222)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = FakeShopAPIClientSpy()
        
        let url = URL(string: "https://fake-url.com")!
        var sut: RemoteShopItemsLoader? = RemoteShopItemsLoader(client: client, url: url)
        
        var capturedResults = [RemoteShopItemsLoader.Result]()
        
        sut?.load(completion: { result in
            capturedResults.append(result)
        })
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    // MARK: Helpers
    
    private func failure(_ error: RemoteShopItemsLoader.Error) -> RemoteShopItemsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: Int, title: String, price: Double, description: String?, category: String, image: String, rate: Double, userCount: Int) -> (model: ShopItem, json: [String: Any]) {
        let item = ShopItem(id: id,
                             title: title,
                             price: price,
                             category: category,
                             description: description,
                             imageURL: image,
                             rating: Rating(rate: rate,
                                            userCount: userCount))
        
        var itemJSON: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "price": item.price,
            "category": item.category,
            "image": item.imageURL,
            "rating": [
                "rate": item.rating.rate,
                "count": item.rating.userCount
            ]
        ]
        
        // Adding the description only if it's not nil
        if let description = item.description {
            itemJSON["description"] = description
        }
        
        return (item, itemJSON)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
            let itemsJSON = items
            return try! JSONSerialization.data(withJSONObject: itemsJSON)
        }

    
    private func makeSUT(url: URL = URL(string:"https://fakestoreapi.com/products")!) -> (sut: RemoteShopItemsLoader, client: FakeShopAPIClientSpy) {
        let client = FakeShopAPIClientSpy()
        let sut = RemoteShopItemsLoader(client: client, url: url)
        
        trackForMemoryLeaks(sut, file: #file, line: #line)
        trackForMemoryLeaks(client, file: #file, line: #line)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteShopItemsLoader,
                        toCompleteWithResult expectedResult: RemoteShopItemsLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
    
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteShopItemsLoader.Error), .failure(expectedError as RemoteShopItemsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

class FakeShopAPIClientSpy: FakeShopAPIClient {
    // Todo: Replace spy captured params with messages
    
    private var messages = [(url: URL, completion: (FakeShopAPIClientResult) -> Void)]()
    
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (FakeShopAPIClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        messages[index].completion(.success(data, response))
    }
}

