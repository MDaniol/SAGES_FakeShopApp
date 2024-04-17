//
//  DBModelMigrationV1toV2.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 13/04/2024.
//

import Foundation

import CoreData

class DBModelMigrationV1toV2: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        let sourceKeys = sInstance.entity.attributesByName.keys
        let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys.map { $0 as String })
        
        let destinationInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
        let destinationKeys = destinationInstance.entity.attributesByName.keys.map { $0 as String }
        
        for key in destinationKeys {
            if let value = sourceValues[key] {
                destinationInstance.setValue(value, forKey: key)
            }
        }
        
        if destinationInstance.value(forKey: "imageURL") == nil {
            destinationInstance.setValue("", forKey: "imageURL")
        }
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationInstance, for: mapping)
    }
}
