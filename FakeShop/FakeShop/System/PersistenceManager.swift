//
//  SceneDelegate.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation
import UIKit
import CoreData

public class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private init() {}
    
    public lazy var store: ShopItemsStore = {
        do {
            return try CoreDataShopItemStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("shop-item-store.sqlite"),
                                             contextQueue: .background)
        } catch {
            return InMemoryShopItemStore()
        }
    }()
}
