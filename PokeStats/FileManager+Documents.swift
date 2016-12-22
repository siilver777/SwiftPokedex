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
        return docummentsURL(childPath: nil)
    }
    
    public static func docummentsURL(childPath: String?) -> URL? {
        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if let childPath = childPath {
                return documentURL.appendingPathComponent(childPath)
            }
            return documentURL
        }
        return nil
    }
}
