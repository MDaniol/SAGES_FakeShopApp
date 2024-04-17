//
//  ServicesHelpers.swift
//  FakeShop
//
//  Created by Mateusz Danioł on 14/04/2024.
//

import Foundation

class ServicesHelpers {
    static func getApplicationSupportDirectory() -> URL? {
        let fileManager = FileManager.default
        do {
            // Get the URL for the Application Support directory in the user domain
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            return appSupportURL
        } catch {
            print("Error getting the Application Support directory: \(error)")
            return nil
        }
    }
}
