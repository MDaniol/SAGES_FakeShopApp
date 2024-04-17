//
//  CoreDataStack.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 13/04/2024.
//

import Foundation
import CoreData
import FakeAPIClient

public final class CoreDataShopItemStore {
    private static let modelName = "db_model"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataShopItemStore.self))
    
    private let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public enum ContextQueue {
        case main
        case background
    }
    
    public init(storeURL: URL, contextQueue: ContextQueue) throws {
        
        UserDefaults.standard.set(true, forKey: "com.apple.CoreData.SQLDebug")
        UserDefaults.standard.set(true, forKey: "com.apple.CoreData.MigrationDebug")
        
        guard let model = CoreDataShopItemStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataShopItemStore.modelName, model: model, url: storeURL)
            context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
}



extension CoreDataShopItemStore: ShopItemsStore {
    public func deleteCachedShopItems() throws {// Creating new context each time assures thread safety
        
        try context.performAndWait {
            let request: NSFetchRequest<DBShopItem> = DBShopItem.fetchRequest()
            
            do {
                let items = try context.fetch(request)
                for item in items {
                    context.delete(item)
                }
                
                if context.hasChanges {
                    try context.save()
                }
            } catch(let error) {
                context.rollback()
                throw error
            }
        }
    }
    
    public func retrieve(completion: @escaping (Result<[CachedShopItem], Error>) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<DBShopItem> = DBShopItem.fetchRequest()
            do {
                let dbShopItems = try self.context.fetch(fetchRequest)
                completion(.success(dbShopItems.map { CachedShopItem.from(entity: $0 )}))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieveFilteredItems(category: String?, maxPrice: Double?, startingLetter: Character?, completion: @escaping (Result<[CachedShopItem], Error>) -> Void) {
        
        context.perform {
            
            let fetchRequest: NSFetchRequest<DBShopItem> = DBShopItem.fetchRequest()
            
            var predicates: [NSPredicate] = []
            
            if let category = category {
                predicates.append(NSPredicate(format: "category == %@", category))
            }
            
            if let maxPrice = maxPrice {
                predicates.append(NSPredicate(format: "price <= %f", maxPrice))
            }
            
            if let startingLetter = startingLetter {
                predicates.append(NSPredicate(format: "title BEGINSWITH[c] %@", String(startingLetter)))
            }
            
            if !predicates.isEmpty {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            do {
                let dbShopItems = try self.context.fetch(fetchRequest)
                completion(.success(dbShopItems.map { CachedShopItem.from(entity: $0)}))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(shopItem: LocalShopItem) {
        context.perform {
            let newDbShopItem = DBShopItem(context: self.context)
            newDbShopItem.id = Int32(shopItem.id)
            newDbShopItem.price = shopItem.price
            newDbShopItem.title = shopItem.title
            newDbShopItem.category = shopItem.category
            newDbShopItem.imageURL = shopItem.imageURL
            newDbShopItem.item_description = shopItem.description
            
            do {
                try self.context.save()
            } catch {
                fatalError("Failed to save LocalShopItem: \(shopItem), due to an error: \(error)", file: #file, line: #line)
            }
        }
    }
    
    
}

extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = false
        }
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

class CoreDataStack: ObservableObject {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        // For debugging CoreData Operations
        UserDefaults.standard.set(true, forKey: "com.apple.CoreData.SQLDebug")
        UserDefaults.standard.set(true, forKey: "com.apple.CoreData.MigrationDebug")
        
        let container = NSPersistentContainer(name: "db_model")
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = false
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                // TODO: Handle the error appropriately.
                fatalError("Error initialization persistent store: \(error)", file: #file, line: #line)
            }
            // Print the URL of the loaded store
            if let url = storeDescription.url {
                print("Persistent Store URL: \(url)")
            }
        }
        return container
    }()
}

extension CoreDataStack: ShopItemsStore {
    
    func deleteCachedShopItems() throws {
        let context = persistentContainer.newBackgroundContext() // Creating new context each time assures thread safety
        
        try context.performAndWait {
            let request: NSFetchRequest<DBShopItem> = DBShopItem.fetchRequest()
            
            do {
                let items = try context.fetch(request)
                for item in items {
                    context.delete(item)
                }
                
                if context.hasChanges {
                    try context.save()
                }
            } catch(let error) {
                context.rollback()
                throw error
            }
        }
    }
    
    func retrieve(completion: @escaping (Result<[CachedShopItem], Error>) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<DBShopItem> = DBShopItem.fetchRequest()
            do {
                let dbShopItems = try context.fetch(fetchRequest)
                completion(.success(dbShopItems.map { CachedShopItem.from(entity: $0 )}))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(shopItem: LocalShopItem) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            let newDbShopItem = DBShopItem(context: context)
            newDbShopItem.id = Int32(shopItem.id)
            newDbShopItem.price = shopItem.price
            newDbShopItem.title = shopItem.title
            newDbShopItem.category = shopItem.category
            newDbShopItem.imageURL = shopItem.imageURL
            newDbShopItem.item_description = shopItem.description
            
            do {
                try context.save()
            } catch {
                fatalError("Failed to save LocalShopItem: \(shopItem), due to an error: \(error)", file: #file, line: #line)
            }
        }
    }
}

