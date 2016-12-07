//
//  NetworkFunctions.swift
//  PokeStats
//
//  Created by Jason Pierna on 07/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

let websiteURL = "http://pokeapi.co/api/v2/"

func request(string urlString: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
    print(urlString)
    if let url = URL(string: urlString) {
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: completion)
        task.resume()
    }
}
