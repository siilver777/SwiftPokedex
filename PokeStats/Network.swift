//
//  Network.swift
//  PokeStats
//
//  Created by Jason Pierna on 07/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

/**
 The Network class hosts static methods related to networking actions (requests, download…).
*/
class Network {
    
    /**
     Lets us make a aysnc network request.
     - parameter string: the URL string for the request.
     - parameter completion: block called at the end of the request.
     */
    public static func request(string urlString: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print(urlString)
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: completion)
            task.resume()
        }
    }
}
