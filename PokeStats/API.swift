//
//  API.swift
//  PokeStats
//
//  Created by Jason Pierna on 07/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

class API {
    static let baseURL = "http://pokeapi.co/api/v2/"
    
    static var pokemon: String {
        return baseURL + "pokemon/"
    }
    
    static func pokemon(no: Int) -> String {
        return pokemon + String(no) + "/"
    }
    
    
}
