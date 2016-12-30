//
//  FileManager+Documents.swift
//  PokeStats
//
//  Created by Jason Pierna on 17/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

extension FileManager {
    
    public static func documentsURL() -> URL? {
        return documentsURL(childPath: nil)
    }
    
    public static func documentsURL(childPath: String?) -> URL? {
        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print(documentURL)
            if let childPath = childPath {
                return documentURL.appendingPathComponent(childPath)
            }
            return documentURL
        }
        return nil
    }
}
