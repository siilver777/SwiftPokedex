//
//  Pokémon.swift
//  PokeStats
//
//  Created by Jason Pierna on 11/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit
import SwiftyJSON

class Pokémon: NSObject {
    var id: Int!
    var name: String!
    var pokedexDescription: String!
    var height: Double!
    var weight: Double!
    
    var type1: Type!
    var type2: Type?
    
    var stats: Stats
    
    init(json: JSON) {
        
        // Base info
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.pokedexDescription = json["description"].stringValue
        self.height = json["height"].doubleValue
        self.weight = json["weight"].doubleValue
        
        // Types
        let types = json["types"].arrayValue
        self.type1 = Type(rawValue: types[0]["id"].intValue)!
        
        if types.count > 1 {
            self.type2 = Type(rawValue: types[1]["id"].intValue)!
        }
        
        // Stats
        self.stats = Stats(pv: json["stats"]["pv"].intValue,
                           atk: json["stats"]["atk"].intValue,
                           def: json["stats"]["def"].intValue,
                           atkspe: json["stats"]["atkspe"].intValue,
                           defspe: json["stats"]["defspe"].intValue,
                           vit: json["stats"]["vit"].intValue)
    }
}
